import 'dart:async'; // Importar dart:async para Timer
import 'dart:convert'; // Importar dart:convert para jsonDecode
import 'dart:developer' as developer;
import 'dart:io';

import 'package:arcinus/features/app/academy/core/services/academy_controller.dart';
import 'package:arcinus/features/app/academy/core/services/academy_provider.dart';
import 'package:arcinus/features/app/sports/core/models/sport_characteristics.dart';
import 'package:arcinus/features/location/place_details.dart';
import 'package:arcinus/features/location/place_prediction.dart';
import 'package:arcinus/features/navigation/components/base_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importar dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http; // Importar http
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; // Importar uuid para session token

class CreateAcademyScreen extends ConsumerStatefulWidget {
  const CreateAcademyScreen({super.key});

  @override
  ConsumerState<CreateAcademyScreen> createState() => _CreateAcademyScreenState();
}

class _CreateAcademyScreenState extends ConsumerState<CreateAcademyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationSearchController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSport;
  File? _logoFile;
  bool _isLoading = false;
  bool _isSearching = false; // Para mostrar indicador de carga en predicciones
  Timer? _debounce; // Para retrasar llamadas API
  List<PlacePrediction> _predictions = []; // Lista de predicciones
  PlaceDetails? _selectedPlaceDetails; // Detalles del lugar seleccionado
  String _sessionToken = const Uuid().v4(); // Session token para Google Places API
  
  // Lista de deportes disponibles con códigos normalizados
  final Map<String, String> _sports = {
    'basketball': 'Baloncesto',
    'volleyball': 'Voleibol',
    'skating': 'Patinaje',
    'soccer': 'Fútbol',
    'futsal': 'Fútbol de Salón',
    'otro': 'Otro'
  };

  // API Key desde .env
  final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    // Listener para el campo de búsqueda
    _locationSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancelar el timer si existe
    _nameController.dispose();
    _addressController.dispose();
    _locationSearchController.removeListener(_onSearchChanged); // Remover listener
    _locationSearchController.dispose();
    _taxIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Método llamado cuando cambia el texto de búsqueda
  void _onSearchChanged() {
    // Si hay un timer activo, cancelarlo
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Si el campo está vacío, limpiar predicciones inmediatamente
    if (_locationSearchController.text.isEmpty) {
      setState(() {
        _predictions = [];
      });
      return;
    }
    
    // Iniciar un nuevo timer para esperar 500ms antes de buscar
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_locationSearchController.text.isNotEmpty && _apiKey.isNotEmpty) {
        _fetchPlacePredictions(_locationSearchController.text);
      } else {
        // Limpiar predicciones si el campo está vacío o no hay API Key
        setState(() {
          _predictions = [];
        });
      }
    });
  }

  // Obtener predicciones de lugares desde Google Places Autocomplete API
  Future<void> _fetchPlacePredictions(String input) async {
    setState(() {
      _isSearching = true; // Mostrar indicador de carga
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=$input'
      '&key=$_apiKey'
      '&sessiontoken=$_sessionToken'
      // '&components=country:co' // Descomentar para limitar a Colombia
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            final predictionsList = data['predictions'] as List<dynamic>; 
            _predictions = predictionsList
                .map((p) => PlacePrediction.fromJson(p as Map<String, dynamic>))
                .toList();
            _isSearching = false;
          });
        } else {
          // Manejar errores de la API (ej. ZERO_RESULTS, REQUEST_DENIED)
          developer.log('Places API Error (Autocomplete): ${data['status']} - ${data['error_message']}');
          setState(() {
            _predictions = [];
            _isSearching = false;
          });
          _showApiErrorSnackbar(data['status'] as String);
        }
      } else {
        // Manejar errores de HTTP
        developer.log('HTTP Error (Autocomplete): ${response.statusCode}');
        setState(() {
          _predictions = [];
          _isSearching = false;
        });
        _showApiErrorSnackbar('HTTP_${response.statusCode}');
      }
    } catch (e) {
      developer.log('Exception (Autocomplete): $e');
      setState(() {
        _predictions = [];
        _isSearching = false;
      });
      _showApiErrorSnackbar('EXCEPTION');
    }
  }

  // Obtener detalles de un lugar desde Google Places Details API
  Future<void> _fetchPlaceDetails(String placeId) async {
    // Limpiar predicciones y mostrar carga
    setState(() {
      _predictions = [];
      _isLoading = true; // Usar isLoading general o uno específico
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&key=$_apiKey'
      '&fields=formatted_address,geometry/location,place_id' // Campos que queremos
      '&sessiontoken=$_sessionToken'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'] as Map<String, dynamic>; 
          final geometry = result['geometry'] as Map<String, dynamic>; 
          final location = geometry['location'] as Map<String, dynamic>; 

          // Actualizar estado con los detalles y rellenar campos
          setState(() {
            _selectedPlaceDetails = PlaceDetails(
              formattedAddress: result['formatted_address'] as String,
              latitude: location['lat'] as double,
              longitude: location['lng'] as double,
              placeId: result['place_id'] as String,
            );
            // Actualizar controllers (opcional, depende de la UX deseada)
            _locationSearchController.text = _selectedPlaceDetails!.formattedAddress;
            // _addressController.text = ""; // O quizás algún detalle específico?
            _isLoading = false;
            // Asegurar que las predicciones están vacías para ocultar el dropdown
            _predictions = [];
          });
           // Generar nuevo session token para la próxima búsqueda
          _sessionToken = const Uuid().v4();

        } else {
          developer.log('Places API Error (Details): ${data['status']} - ${data['error_message']}');
           setState(() { 
             _isLoading = false; 
             _predictions = []; // Asegurar que las predicciones están vacías
           });
           _showApiErrorSnackbar(data['status'] as String);
           _resetLocationSearch(); // Resetear token y estado
        }
      } else {
        developer.log('HTTP Error (Details): ${response.statusCode}');
         setState(() { 
           _isLoading = false; 
           _predictions = []; // Asegurar que las predicciones están vacías
         });
        _showApiErrorSnackbar('HTTP_${response.statusCode}');
        _resetLocationSearch(); // Resetear token y estado
      }
    } catch (e) {
      developer.log('Exception (Details): $e');
       setState(() { 
         _isLoading = false; 
         _predictions = []; // Asegurar que las predicciones están vacías
       });
       _showApiErrorSnackbar('EXCEPTION');
       _resetLocationSearch(); // Resetear token y estado
    }
  }

  // Mostrar Snackbar para errores de API
  void _showApiErrorSnackbar(String errorCode) {
    String message;
    switch (errorCode) {
      case 'ZERO_RESULTS':
        message = 'No se encontraron lugares.';
        break;
      case 'REQUEST_DENIED':
        message = 'Error de API Key o servicio no habilitado.';
        break;
      case 'INVALID_REQUEST':
        message = 'Error en la solicitud a la API.';
        break;
      default:
        message = 'Error al buscar ubicación. Intenta de nuevo.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Resetear búsqueda de ubicación y token
  void _resetLocationSearch() {
     setState(() {
        _locationSearchController.clear();
        _predictions = [];
        _selectedPlaceDetails = null;
        _sessionToken = const Uuid().v4(); // Generar nuevo token
      });
  }

  // Método para seleccionar logo desde galería
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  // Método para crear la academia
  Future<void> _createAcademy() async {
    if (!_formKey.currentState!.validate() || _selectedSport == null) {
      // Mostrar error si no se ha seleccionado deporte
      if (_selectedSport == null) {
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Validación fallida: deporte no seleccionado');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona un deporte')),
        );
      } else {
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Validación fallida: formulario inválido');
      }
      return;
    }
    
    developer.log('DEBUG: CreateAcademyScreen._createAcademy - Validación exitosa, iniciando creación');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Crear academia
      final academyController = ref.read(academyControllerProvider);
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Obtenido controlador de academia');
      
      // Obtener características del deporte
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Deporte seleccionado: $_selectedSport');
      final sportConfig = _selectedSport == 'otro' 
          ? null 
          : SportCharacteristics.forSport(_selectedSport!);
      
      // Convertir SportCharacteristics a Map<String, dynamic> para evitar errores de serialización
      final sportConfigMap = sportConfig?.toJson();
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - SportConfig generado: ${sportConfigMap != null ? 'sí' : 'no'}');
      
      // --- Usar los detalles del lugar seleccionado ---
      String? finalFormattedAddress = _selectedPlaceDetails?.formattedAddress;
      // Si no se seleccionó lugar pero se escribió algo en el campo de dirección, usarlo.
      if (finalFormattedAddress == null && _addressController.text.trim().isNotEmpty) {
         finalFormattedAddress = _addressController.text.trim();
      }
      // ----------------------------------------------

      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Llamando a academyController.createAcademy');
      final academy = await academyController.createAcademy(
        name: _nameController.text.trim(),
        sport: _sports[_selectedSport!] ?? _selectedSport!,
        academyFormattedAddress: finalFormattedAddress,
        academyLatitude: _selectedPlaceDetails?.latitude,
        academyLongitude: _selectedPlaceDetails?.longitude,
        academyGooglePlaceId: _selectedPlaceDetails?.placeId,
        taxId: _taxIdController.text.trim().isNotEmpty ? _taxIdController.text.trim() : null,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        sportConfig: sportConfigMap,
      );
      
      developer.log('DEBUG: CreateAcademyScreen._createAcademy - Academia creada exitosamente: ${academy.academyId}');
      
      // Subir logo si se seleccionó
      if (_logoFile != null) {
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Subiendo logo para academia ${academy.academyId}');
        await academyController.uploadAcademyLogo(
          academy.academyId,
          _logoFile!.path,
        );
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Logo subido exitosamente');
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        developer.log('DEBUG: CreateAcademyScreen._createAcademy - Navegando al dashboard');
        // Navegar al dashboard (ahora a /main)
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Usar unawaited intencionalmente para permitir la navegación inmediata
        // ignore: unawaited_futures
        Navigator.pushReplacementNamed(context, '/main');
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Academia creada con éxito!')),
        );
      }
    } catch (e) {
      developer.log('ERROR: CreateAcademyScreen._createAcademy - Error al crear academia: $e', error: e);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar un mensaje más informativo para el error específico
        String errorMessage = e.toString();
        if (errorMessage.contains('propietario ya tiene una academia')) {
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Error de academia duplicada');
          // Si es el error específico de academia duplicada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Un propietario solo puede tener una academia. No es posible crear múltiples academias.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          
          // Redirigir al dashboard donde verá su academia existente
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Redirigiendo al dashboard después de error de academia duplicada');
          Navigator.of(context).popUntil((route) => route.isFirst);
          await Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (errorMessage.contains('not-found')) {
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Error de documento no encontrado: $errorMessage');
          // Error específico de documento no encontrado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear academia: Documento no encontrado. Contacta al soporte técnico.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 7),
            ),
          );
        } else {
          // Para otros errores
          developer.log('DEBUG: CreateAcademyScreen._createAcademy - Error general: $errorMessage');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear la academia: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsAcademyCreation = ref.watch(needsAcademyCreationProvider);
    
    return BaseScaffold(
      showNavigation: false,
      appBar: AppBar(
        title: const Text('Crear Academia'),
        // Mostrar botón de cancelar solo si no es obligatoria la creación
        leading: needsAcademyCreation.maybeWhen(
          data: (needsCreation) => needsCreation ? null : const BackButton(),
          orElse: () => const BackButton(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Si es obligatorio crear academia, mostrar mensaje explicativo
              needsAcademyCreation.maybeWhen(
                data: (needsCreation) => needsCreation
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Información',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Para comenzar a usar la aplicación, primero debes crear una academia deportiva.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                orElse: () => const SizedBox.shrink(),
              ),
              
              // Logo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      image: _logoFile != null
                          ? DecorationImage(
                              image: FileImage(_logoFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _logoFile == null
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Campo de nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Academia',
                  hintText: 'Ej. Academia Deportiva Campeones',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Selector de deporte
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Deporte',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSport,
                hint: const Text('Selecciona un deporte'),
                items: _sports.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedSport = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // --- Campo de búsqueda de ubicación y lista de predicciones ---
              TextFormField(
                controller: _locationSearchController,
                enabled: !_isLoading, // Deshabilitar mientras se cargan detalles
                decoration: InputDecoration(
                  labelText: 'Buscar Ubicación (Nombre, Ciudad)',
                  hintText: 'Ej. Estadio El Campín, Bogotá',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: _locationSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _resetLocationSearch, // Limpiar campo y estado
                        )
                      : null,
                ),
                readOnly: _selectedPlaceDetails != null, // Hacer readonly si ya se seleccionó algo
                onTap: _selectedPlaceDetails != null ? _resetLocationSearch : null, // Resetear si se toca cuando está readonly
              ),
              // Mostrar lista de predicciones o indicador de carga
              if (_apiKey.isEmpty && _locationSearchController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('API Key no configurada.', style: TextStyle(color: Colors.red)),
                )
              else if (_isSearching)
                 const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                 )
              else if (_predictions.isNotEmpty && _selectedPlaceDetails == null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200), // Limitar altura
                  child: ListView.builder(
                    shrinkWrap: true, // Ajustar al contenido
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_pin),
                        title: Text(prediction.description),
                        onTap: () {
                          // Ocultar teclado al seleccionar
                          FocusScope.of(context).unfocus();
                          _fetchPlaceDetails(prediction.placeId);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // ---------------------------------------------------------------

              // Campo de Dirección (detalle manual)
              TextFormField(
                controller: _addressController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Dirección (Detalle adicional, opcional)',
                  hintText: 'Ej. Oficina 301, Interior 5',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de NIT
              TextFormField(
                controller: _taxIdController,
                decoration: const InputDecoration(
                  labelText: 'NIT o Identificador Fiscal',
                  hintText: 'Ej. 901.234.567-8',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe brevemente tu academia deportiva',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OutlinedButton(
                        onPressed: needsAcademyCreation.maybeWhen(
                          data: (needsCreation) => needsCreation 
                            ? null  // Deshabilitamos si es obligatorio crear
                            : (_isLoading ? null : () => Navigator.pop(context)),
                          orElse: () => _isLoading ? null : () => Navigator.pop(context),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createAcademy,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Crear Academia'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Espacio adicional al final
            ],
          ),
        ),
      ),
    );
  }
} 