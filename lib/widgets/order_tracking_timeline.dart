import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../data/models/order_model.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingTimeline({
    super.key,
    required this.order,
  });

  static const List<String> _stages = [
    'تم استلام الطلب',
    'تم تأكيد الطلب',
    'جاري تجهيز الطلب',
    'خرج الطلب للتوصيل',
    'تم تسليم الطلب',
  ];

  DateTime? _timestampForStage(String stageTitle) {
    for (final record in order.timeline) {
      if (record.step == stageTitle) {
        return record.at;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.status == OrderStatus.cancelled;
    final currentStageIndex = order.status.timelineStageIndex;
    final isFullyDelivered = order.status == OrderStatus.delivered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCancelled) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.cancel_rounded, color: AppColors.error, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'تم إلغاء هذا الطلب وتوقف التتبع.',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ...List.generate(_stages.length, (index) {
          final stageTitle = _stages[index];
          final stageTime = _timestampForStage(stageTitle);
          final isLast = index == _stages.length - 1;

          final bool isCompleted;
          final bool isCurrent;

          if (isCancelled) {
            isCompleted = stageTime != null;
            isCurrent = false;
          } else if (isFullyDelivered) {
            isCompleted = true;
            isCurrent = false;
          } else {
            isCompleted = index < currentStageIndex;
            isCurrent = index == currentStageIndex;
          }

          final Color nodeColor = isCompleted
              ? AppColors.success
              : isCurrent
                  ? AppColors.primary
                  : AppColors.pending;

          final Color lineColor =
              isCompleted ? AppColors.success : AppColors.border;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isCurrent ? 28 : 24,
                        height: isCurrent ? 28 : 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.successSoft
                              : isCurrent
                                  ? AppColors.secondary
                                  : AppColors.pendingSoft,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: nodeColor,
                            width: isCurrent ? 2 : 1.5,
                          ),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : isCurrent
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.circle,
                          size: isCompleted
                              ? 15
                              : isCurrent
                                  ? 16
                                  : 8,
                          color: nodeColor,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2.2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: lineColor,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: isCurrent
                          ? const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            )
                          : const EdgeInsets.symmetric(vertical: 2),
                      decoration: isCurrent
                          ? BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            )
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stageTitle,
                                  style: TextStyle(
                                    color: isCurrent
                                        ? AppColors.primary
                                        : isCompleted
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                    fontSize: isCurrent ? 14.5 : 13.5,
                                    fontWeight: isCurrent || isCompleted
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'المرحلة الحالية',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (stageTime != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              AppFormatters.formatDateTime(stageTime),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ] else if (!isCompleted && !isCurrent) ...[
                            const SizedBox(height: 2),
                            Text(
                              isCancelled ? 'لم يتم الوصول' : 'قيد الانتظار',
                              style: const TextStyle(
                                color: AppColors.pending,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}