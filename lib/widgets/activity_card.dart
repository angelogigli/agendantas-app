import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isWorkshop;
  final VoidCallback? onTap;
  final VoidCallback? onBook;
  final VoidCallback? onUnbook;

  const ActivityCard({
    super.key,
    required this.activity,
    this.isWorkshop = false,
    this.onTap,
    this.onBook,
    this.onUnbook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Data
              _buildDateBox(),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWorkshop
                          ? (activity.descrizione.isNotEmpty
                              ? activity.descrizione
                              : activity.tipo)
                          : activity.categoria,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.dataFormatted,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.prenotati}/${activity.maxPartecipanti}',
                          style: TextStyle(
                            color: _getCountColor(),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBox() {
    final date = DateTime.tryParse(activity.data) ?? DateTime.now();
    final months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu',
                    'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];

    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isWorkshop
            ? AppTheme.secondaryColor.withOpacity(0.1)
            : AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isWorkshop ? AppTheme.secondaryColor : AppTheme.primaryColor,
            ),
          ),
          Text(
            months[date.month - 1],
            style: TextStyle(
              fontSize: 12,
              color: isWorkshop ? AppTheme.secondaryColor : AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (activity.isClosed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.textMuted.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Chiuso',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    if (activity.isPrenotato) {
      return IconButton(
        onPressed: onUnbook,
        icon: const Icon(Icons.close),
        color: AppTheme.dangerColor,
        tooltip: 'Cancella',
      );
    }

    return IconButton(
      onPressed: onBook,
      icon: const Icon(Icons.check),
      color: AppTheme.successColor,
      tooltip: 'Prenota',
    );
  }

  Color _getCountColor() {
    if (activity.isFull) return AppTheme.dangerColor;
    if (activity.prenotati >= activity.maxPartecipanti * 0.7) {
      return AppTheme.warningColor;
    }
    return AppTheme.successColor;
  }
}
