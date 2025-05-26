import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget para mostrar y editar las fechas de servicio del pago
class ServiceDatesSection extends StatelessWidget {
  final DateTime? serviceStartDate;
  final DateTime? serviceEndDate;
  final bool showStartDateSelector;
  final VoidCallback? onSelectServiceStartDate;

  const ServiceDatesSection({
    super.key,
    this.serviceStartDate,
    this.serviceEndDate,
    required this.showStartDateSelector,
    this.onSelectServiceStartDate,
  });

  @override
  Widget build(BuildContext context) {
    if (serviceStartDate == null || serviceEndDate == null) {
      return const SizedBox.shrink();
    }

    final daysRemaining = serviceEndDate!.difference(DateTime.now()).inDays;
    final totalDays = serviceEndDate!.difference(serviceStartDate!).inDays;
    final progressPercentage = totalDays > 0 
        ? ((totalDays - daysRemaining) / totalDays).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(daysRemaining),
            const SizedBox(height: 12),
            
            // Barra de progreso del período
            if (totalDays > 0) ...[
              _buildProgressIndicator(progressPercentage, daysRemaining),
              const SizedBox(height: 12),
            ],
            
            // Fechas del servicio
            _buildServiceDates(),
            
            // Advertencias y notas
            if (showStartDateSelector) ...[
              const SizedBox(height: 12),
              _buildEditableNote(),
            ],
            
            // Advertencia si la fecha de inicio es retroactiva
            if (_isRetroactiveStartDate()) ...[
              const SizedBox(height: 8),
              _buildRetroactiveWarning(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int daysRemaining) {
    return Row(
      children: [
        const Icon(Icons.date_range, color: Colors.green, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Período de Servicio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (daysRemaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: daysRemaining <= 7 ? Colors.orange : Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$daysRemaining días restantes',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(double progressPercentage, int daysRemaining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progressPercentage,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            daysRemaining <= 7 ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Progreso del período: ${(progressPercentage * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildServiceDates() {
    final totalDays = serviceEndDate!.difference(serviceStartDate!).inDays;

    return Column(
      children: [
        // Fecha de inicio del servicio
        _buildDateRow(
          Icons.play_arrow,
          Colors.green,
          'Fecha de inicio:',
          serviceStartDate!,
          isEditable: showStartDateSelector,
          onTap: onSelectServiceStartDate,
        ),
        const SizedBox(height: 8),
        
        // Fecha de fin del servicio
        _buildDateRow(
          Icons.stop,
          Colors.red,
          'Fecha de fin:',
          serviceEndDate!,
          isEditable: false,
        ),
        const SizedBox(height: 8),
        
        // Duración del servicio
        Row(
          children: [
            const Icon(Icons.schedule, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Duración:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$totalDays días',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRow(
    IconData icon,
    Color iconColor,
    String label,
    DateTime date, {
    bool isEditable = false,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Expanded(
          child: isEditable && onTap != null
              ? InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(date),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, size: 14, color: Colors.green),
                      ],
                    ),
                  ),
                )
              : Row(
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(date),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    if (!isEditable) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.lock, size: 14, color: Colors.grey),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildEditableNote() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: Colors.blue, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Puedes modificar la fecha de inicio tocando el campo de fecha',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroactiveWarning() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'La fecha de inicio es anterior a hoy. Esto puede afectar el cálculo de días restantes.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  bool _isRetroactiveStartDate() {
    return serviceStartDate != null && 
           serviceStartDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }
} 