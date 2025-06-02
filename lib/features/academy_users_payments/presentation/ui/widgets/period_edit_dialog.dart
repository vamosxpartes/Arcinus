import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/academy_users_subscriptions/data/models/subscription_assignment_model.dart';

/// Diálogo para editar las fechas de un período
class PeriodEditDialog extends ConsumerStatefulWidget {
  final SubscriptionAssignmentModel period;
  final Function(DateTime startDate, DateTime endDate, String? notes) onSave;

  const PeriodEditDialog({
    super.key,
    required this.period,
    required this.onSave,
  });

  @override
  ConsumerState<PeriodEditDialog> createState() => _PeriodEditDialogState();
}

class _PeriodEditDialogState extends ConsumerState<PeriodEditDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startDate = widget.period.startDate;
    _endDate = widget.period.endDate;
    _notesController = TextEditingController(text: widget.period.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.mediumGray,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        side: BorderSide(
          color: AppTheme.courtGreen.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: AppTheme.courtGreen.withAlpha(20),
                      borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                    ),
                    child: const Icon(
                      Icons.edit_calendar,
                      color: AppTheme.courtGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  const Expanded(
                    child: Text(
                      'Editar Período',
                      style: TextStyle(
                        fontSize: AppTheme.h3Size,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.magnoliaWhite,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Advertencia si es período activo
              if (widget.period.status == SubscriptionAssignmentStatus.active)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.goldTrophy.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppTheme.spacingSm),
                    border: Border.all(
                      color: AppTheme.goldTrophy.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: AppTheme.goldTrophy,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          'Este es un período activo. Los cambios afectarán la suscripción actual.',
                          style: TextStyle(
                            fontSize: AppTheme.secondarySize,
                            color: AppTheme.goldTrophy,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Fecha de inicio
              _buildDateField(
                label: 'Fecha de Inicio',
                date: _startDate,
                onTap: () => _selectDate(isStartDate: true),
                enabled: widget.period.status != SubscriptionAssignmentStatus.active ||
                        _startDate.isAfter(DateTime.now()),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Fecha de fin
              _buildDateField(
                label: 'Fecha de Fin',
                date: _endDate,
                onTap: () => _selectDate(isStartDate: false),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Campo de notas
              _buildNotesField(),
              const SizedBox(height: AppTheme.spacingLg),

              // Información de duración
              _buildDurationInfo(),
              const SizedBox(height: AppTheme.spacingLg),

              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppTheme.spacingSm),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: enabled 
                  ? AppTheme.darkGray 
                  : AppTheme.darkGray.withAlpha(50),
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              border: Border.all(
                color: enabled 
                    ? AppTheme.lightGray.withAlpha(30) 
                    : AppTheme.lightGray.withAlpha(10),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: enabled ? AppTheme.lightGray : AppTheme.lightGray.withAlpha(50),
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: AppTheme.bodySize,
                    color: enabled 
                        ? AppTheme.magnoliaWhite 
                        : AppTheme.magnoliaWhite.withAlpha(100),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!enabled) ...[
                  const Spacer(),
                  Icon(
                    Icons.lock,
                    color: AppTheme.lightGray.withAlpha(50),
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notas (Opcional)',
          style: TextStyle(
            fontSize: AppTheme.bodySize,
            fontWeight: FontWeight.w600,
            color: AppTheme.magnoliaWhite,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: TextStyle(
            color: AppTheme.magnoliaWhite,
            fontSize: AppTheme.bodySize,
          ),
          decoration: InputDecoration(
            hintText: 'Agrega notas sobre los cambios realizados...',
            hintStyle: TextStyle(
              color: AppTheme.lightGray.withAlpha(150),
              fontSize: AppTheme.bodySize,
            ),
            filled: true,
            fillColor: AppTheme.darkGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              borderSide: BorderSide(
                color: AppTheme.lightGray.withAlpha(30),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              borderSide: BorderSide(
                color: AppTheme.lightGray.withAlpha(30),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.spacingSm),
              borderSide: BorderSide(
                color: AppTheme.courtGreen,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo() {
    final duration = _endDate.difference(_startDate).inDays;
    final originalDuration = widget.period.endDate.difference(widget.period.startDate).inDays;
    final isChanged = duration != originalDuration;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: isChanged 
            ? AppTheme.courtGreen.withAlpha(10) 
            : AppTheme.lightGray.withAlpha(10),
        borderRadius: BorderRadius.circular(AppTheme.spacingSm),
        border: Border.all(
          color: isChanged 
              ? AppTheme.courtGreen.withAlpha(30) 
              : AppTheme.lightGray.withAlpha(30),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isChanged ? Icons.update : Icons.info_outline,
            color: isChanged ? AppTheme.courtGreen : AppTheme.lightGray,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duración del período: $duration días',
                  style: TextStyle(
                    fontSize: AppTheme.bodySize,
                    fontWeight: FontWeight.w600,
                    color: isChanged ? AppTheme.courtGreen : AppTheme.magnoliaWhite,
                  ),
                ),
                if (isChanged) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Duración original: $originalDuration días',
                    style: TextStyle(
                      fontSize: AppTheme.secondarySize,
                      color: AppTheme.lightGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasChanges = _startDate != widget.period.startDate ||
                      _endDate != widget.period.endDate ||
                      _notesController.text.trim() != (widget.period.notes ?? '');

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.lightGray),
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.lightGray),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: hasChanges ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasChanges ? AppTheme.courtGreen : AppTheme.mediumGray,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
            ),
            child: Text(
              'Guardar Cambios',
              style: TextStyle(
                color: hasChanges ? AppTheme.magnoliaWhite : AppTheme.lightGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate 
        ? DateTime(2020) 
        : _startDate.add(const Duration(days: 1));
    final lastDate = DateTime(2030);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.courtGreen,
              onPrimary: AppTheme.magnoliaWhite,
              surface: AppTheme.mediumGray,
              onSurface: AppTheme.magnoliaWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          // Si la fecha de inicio es después de la fecha de fin, ajustar la fecha de fin
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final notes = _notesController.text.trim();
      widget.onSave(_startDate, _endDate, notes.isEmpty ? null : notes);
      Navigator.of(context).pop();
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 