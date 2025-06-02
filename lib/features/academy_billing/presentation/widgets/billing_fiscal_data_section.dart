import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget para la sección de datos fiscales en la configuración de facturación
class BillingFiscalDataSection extends StatelessWidget {
  /// Controladores de texto
  final TextEditingController legalNameController;
  final TextEditingController nitController;
  final TextEditingController nitDvController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController stateController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  /// Valores de dropdown
  final String taxRegime;
  final String fiscalResponsibility;
  final int defaultVAT;

  /// Opciones de dropdown
  final List<String> taxRegimeOptions;
  final List<String> fiscalResponsibilityOptions;
  final List<int> vatOptions;

  /// Callbacks para cambios
  final Function(String) onTaxRegimeChanged;
  final Function(String) onFiscalResponsibilityChanged;
  final Function(int) onVATChanged;

  /// Constructor
  const BillingFiscalDataSection({
    required this.legalNameController,
    required this.nitController,
    required this.nitDvController,
    required this.addressController,
    required this.cityController,
    required this.stateController,
    required this.phoneController,
    required this.emailController,
    required this.taxRegime,
    required this.fiscalResponsibility,
    required this.defaultVAT,
    required this.taxRegimeOptions,
    required this.fiscalResponsibilityOptions,
    required this.vatOptions,
    required this.onTaxRegimeChanged,
    required this.onFiscalResponsibilityChanged,
    required this.onVATChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos Fiscales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nombre legal
            TextFormField(
              controller: legalNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre o Razón Social',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el nombre legal';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // NIT y DV
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: nitController,
                    decoration: const InputDecoration(
                      labelText: 'NIT',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el NIT';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: nitDvController,
                    decoration: const InputDecoration(
                      labelText: 'DV',
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'DV';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Régimen tributario
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Régimen Tributario',
                border: OutlineInputBorder(),
              ),
              value: taxRegimeOptions.contains(taxRegime) ? taxRegime : null,
              items: taxRegimeOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onTaxRegimeChanged(newValue);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione un régimen tributario';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Responsabilidad fiscal
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Responsabilidad Fiscal',
                border: OutlineInputBorder(),
              ),
              value: fiscalResponsibilityOptions.contains(fiscalResponsibility) ? fiscalResponsibility : null,
              items: fiscalResponsibilityOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onFiscalResponsibilityChanged(newValue);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione una responsabilidad fiscal';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // IVA predeterminado
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'IVA Predeterminado',
                border: OutlineInputBorder(),
              ),
              value: vatOptions.contains(defaultVAT) ? defaultVAT : null,
              items: vatOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value%'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onVATChanged(newValue);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Seleccione un porcentaje de IVA';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Dirección, ciudad y departamento
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese la dirección';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese la ciudad';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: stateController,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el departamento';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Teléfono y email
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el teléfono';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email de Facturación',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el email de facturación';
                }
                if (!value.contains('@')) {
                  return 'Ingrese un email válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
} 