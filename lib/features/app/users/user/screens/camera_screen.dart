import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final Function(String) onImageCaptured;
  final String? userId;
  
  const CameraScreen({
    super.key,
    required this.onImageCaptured,
    this.userId,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  final GlobalKey _cameraPreviewKey = GlobalKey();
  CameraDescription? _currentCamera;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  
  Future<void> _initializeCamera() async {
    developer.log('Inicializando cámara', name: 'CameraScreen');
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Obtener cámaras disponibles
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        developer.log('No se encontraron cámaras disponibles', name: 'CameraScreen');
        return;
      }
      
      // Inicializar la cámara trasera por defecto
      CameraDescription? backCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.back) {
          backCamera = camera;
          break;
        }
      }
      
      _currentCamera = backCamera ?? _cameras!.first;
      
      // Crear y configurar el controlador de la cámara
      await _setupCameraController(_currentCamera!);
      
      developer.log('Cámara inicializada con éxito', name: 'CameraScreen');
    } catch (e) {
      developer.log(
        'Error al inicializar la cámara: $e',
        name: 'CameraScreen',
        error: e,
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _setupCameraController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    // Inicializar el controlador
    await _controller!.initialize();
    
    setState(() {
      _isCameraInitialized = true;
      _isLoading = false;
    });
  }
  
  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2 || _currentCamera == null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Cambiar a la otra cámara
      final int currentIndex = _cameras!.indexOf(_currentCamera!);
      final int newIndex = (currentIndex + 1) % _cameras!.length;
      _currentCamera = _cameras![newIndex];
      
      developer.log(
        'Cambiando a cámara: ${_currentCamera!.lensDirection.toString()}',
        name: 'CameraScreen',
      );
      
      await _setupCameraController(_currentCamera!);
    } catch (e) {
      developer.log(
        'Error al cambiar de cámara: $e',
        name: 'CameraScreen',
        error: e,
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePicture() async {
    developer.log('Iniciando captura de imagen', name: 'CameraScreen');
    
    if (_controller == null || !_controller!.value.isInitialized) {
      developer.log('Error: Cámara no inicializada', name: 'CameraScreen');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Tomar la foto
      final XFile photo = await _controller!.takePicture();
      developer.log('Foto tomada en: ${photo.path}', name: 'CameraScreen');
      
      // Procesar la imagen (recortar en círculo)
      final String processedImagePath = await _processImage(photo.path);
      
      // Devolver la ruta de la imagen procesada
      widget.onImageCaptured(processedImagePath);
      
      // Cerrar la pantalla de cámara
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      developer.log(
        'Error al tomar/procesar la imagen: $e',
        name: 'CameraScreen',
        error: e,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<String> _processImage(String imagePath) async {
    developer.log('Procesando imagen...', name: 'CameraScreen');
    
    try {
      // Obtener dimensiones del área circular de recorte
      final RenderBox renderBox = _cameraPreviewKey.currentContext!.findRenderObject() as RenderBox;
      final Size previewSize = renderBox.size;
      
      // El radio del círculo es el mínimo entre la mitad del ancho y la mitad del alto
      final double circleRadius = math.min(previewSize.width, previewSize.height) * 0.4;
      
      // El centro del círculo
      final Offset circleCenter = Offset(previewSize.width / 2, previewSize.height / 2);
      
      // Cargar la imagen original
      final Uint8List bytes = await File(imagePath).readAsBytes();
      final img.Image? originalImage = img.decodeImage(bytes);
      
      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      
      // Calcular factor de escala entre la vista previa y la imagen real
      final double scaleX = originalImage.width / previewSize.width;
      final double scaleY = originalImage.height / previewSize.height;
      
      // Calcular las dimensiones del recorte en la imagen real
      final double scaledRadius = circleRadius * math.max(scaleX, scaleY);
      final int scaledCenterX = (circleCenter.dx * scaleX).round();
      final int scaledCenterY = (circleCenter.dy * scaleY).round();
      
      // Crear un cuadrado que contenga el círculo
      final int squareSize = (scaledRadius * 2).round();
      final int x = (scaledCenterX - scaledRadius).round();
      final int y = (scaledCenterY - scaledRadius).round();
      
      // Recortar la imagen
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: math.max(0, x),
        y: math.max(0, y),
        width: math.min(squareSize, originalImage.width - x),
        height: math.min(squareSize, originalImage.height - y),
      );
      
      // Redimensionar si es necesario
      img.Image finalImage = croppedImage;
      if (croppedImage.width > 500 || croppedImage.height > 500) {
        finalImage = img.copyResize(
          croppedImage,
          width: 500,
          height: 500,
          interpolation: img.Interpolation.linear,
        );
      }
      
      // Guardar la imagen procesada
      final Directory tempDir = await getTemporaryDirectory();
      final String processedImagePath = path.join(tempDir.path, 'processed_${path.basename(imagePath)}');
      
      // Guardar como JPG con 85% de calidad
      final File processedFile = File(processedImagePath);
      await processedFile.writeAsBytes(img.encodeJpg(finalImage, quality: 85));
      
      developer.log('Imagen procesada guardada en: $processedImagePath', name: 'CameraScreen');
      return processedImagePath;
    } catch (e) {
      developer.log(
        'Error al procesar la imagen: $e',
        name: 'CameraScreen',
        error: e,
      );
      // Si hay un error, devolver la imagen original sin procesar
      return imagePath;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCameraBody(),
    );
  }
  
  Widget _buildCameraBody() {
    if (!_isCameraInitialized) {
      return const Center(
        child: Text(
          'Inicializando cámara...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return Stack(
      key: _cameraPreviewKey,
      children: [
        // Vista previa de la cámara
        Center(
          child: CameraPreview(_controller!),
        ),
        
        // Overlay negro con recorte circular
        CustomPaint(
          size: Size.infinite,
          painter: CircleCutoutPainter(),
        ),
        
        // Texto de instrucción
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Text(
            'Centra tu rostro en el círculo',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withAlpha(80),
                ),
              ],
            ),
          ),
        ),
        
        // Botón para cambiar de cámara
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(
              Icons.flip_camera_ios,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _switchCamera,
          ),
        ),
        
        // Botón de captura
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: _isLoading ? null : _takePicture,
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Painter personalizado para crear el recorte circular
class CircleCutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = math.min(size.width, size.height) * 0.4;
    
    // Dibujar un rectángulo negro que cubre toda la pantalla
    final Paint blackPaint = Paint()
      ..color = Colors.black.withAlpha(150)
      ..style = PaintingStyle.fill;
    
    // Crear un path con un agujero circular
    final Path path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));
    
    canvas.drawPath(path, blackPaint);
    
    // Dibujar borde del círculo
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(Offset(centerX, centerY), radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 