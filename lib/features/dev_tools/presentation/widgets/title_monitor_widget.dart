import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcinus/core/theme/ux/app_theme.dart';
import 'package:arcinus/features/navigation_shells/manager_shell/manager_shell.dart';

/// Widget que monitorea y muestra los cambios de título en tiempo real
class TitleMonitorWidget extends ConsumerStatefulWidget {
  /// Callback que se ejecuta cuando cambia el título
  final Function(String newTitle)? onTitleChanged;
  
  /// Si debe mostrar el historial de títulos
  final bool showHistory;
  
  /// Máximo número de títulos en el historial
  final int maxHistoryItems;

  const TitleMonitorWidget({
    super.key,
    this.onTitleChanged,
    this.showHistory = true,
    this.maxHistoryItems = 10,
  });

  @override
  ConsumerState<TitleMonitorWidget> createState() => _TitleMonitorWidgetState();
}

class _TitleMonitorWidgetState extends ConsumerState<TitleMonitorWidget> {
  List<TitleChangeEvent> _titleHistory = [];
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    
    // Obtener el título inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialTitle = ref.read(titleManagerProvider);
      _addTitleToHistory(initialTitle, 'Inicial');
    });
  }

  void _addTitleToHistory(String title, String source) {
    final event = TitleChangeEvent(
      title: title,
      timestamp: DateTime.now(),
      source: source,
    );
    
    setState(() {
      _titleHistory.insert(0, event);
      
      // Mantener solo los últimos elementos
      if (_titleHistory.length > widget.maxHistoryItems) {
        _titleHistory = _titleHistory.take(widget.maxHistoryItems).toList();
      }
      
      _currentTitle = title;
    });
    
    // Notificar el cambio
    widget.onTitleChanged?.call(title);
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el título actual
    final currentTitle = ref.watch(titleManagerProvider);
    
    // Escuchar cambios en el título
    ref.listen(titleManagerProvider, (previous, current) {
      if (previous != current) {
        _addTitleToHistory(current, 'Navegación');
      }
    });
    
    // Actualizar el título actual si no está inicializado
    if (_currentTitle.isEmpty && currentTitle.isNotEmpty) {
      _currentTitle = currentTitle;
    }

    return Card(
      color: AppTheme.darkGray,
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.monitor,
                  color: AppTheme.goldTrophy,
                  size: 20,
                ),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Monitor de Títulos',
                  style: TextStyle(
                    color: AppTheme.goldTrophy,
                    fontSize: AppTheme.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spacingSm),
            
            // Título actual
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.blackSwarm,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.goldTrophy.withAlpha(60),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Título Actual:',
                    style: TextStyle(
                      color: AppTheme.lightGray,
                      fontSize: AppTheme.secondarySize,
                    ),
                  ),
                  Text(
                    _currentTitle.isNotEmpty ? _currentTitle : 'Sin título',
                    style: TextStyle(
                      color: AppTheme.magnoliaWhite,
                      fontSize: AppTheme.bodySize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Historial de títulos
            if (widget.showHistory && _titleHistory.isNotEmpty) ...[
              SizedBox(height: AppTheme.spacingMd),
              Text(
                'Historial de Cambios:',
                style: TextStyle(
                  color: AppTheme.lightGray,
                  fontSize: AppTheme.secondarySize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppTheme.spacingSm),
              
              // Lista de cambios
              ...(_titleHistory.take(5).map((event) => _buildHistoryItem(event))),
              
              if (_titleHistory.length > 5)
                Padding(
                  padding: EdgeInsets.only(top: AppTheme.spacingXs),
                  child: Text(
                    '... y ${_titleHistory.length - 5} cambios más',
                    style: TextStyle(
                      color: AppTheme.lightGray,
                      fontSize: AppTheme.captionSize,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(TitleChangeEvent event) {
    final timeAgo = _getTimeAgo(event.timestamp);
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacingXs),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldTrophy,
            ),
          ),
          SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    color: AppTheme.magnoliaWhite,
                    fontSize: AppTheme.secondarySize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$timeAgo • ${event.source}',
                  style: TextStyle(
                    color: AppTheme.lightGray,
                    fontSize: AppTheme.captionSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else {
      return 'Hace ${difference.inHours}h';
    }
  }
}

/// Modelo para representar un evento de cambio de título
class TitleChangeEvent {
  final String title;
  final DateTime timestamp;
  final String source;

  const TitleChangeEvent({
    required this.title,
    required this.timestamp,
    required this.source,
  });
} 