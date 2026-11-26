import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/offline_banner.dart';
import '../../../widgets/order_card.dart';
import '../../../widgets/order_summary_card.dart';
import '../../../widgets/state_views.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.orders.isEmpty) {
            return const AppLoadingView(message: 'جاري تحميل طلباتك...');
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.orders.isEmpty) {
            return AppErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.loadOrders,
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.loadOrders(isRefresh: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        if (controller.isFromCache.value) ...[
                          const SizedBox(height: 14),
                          const OfflineBanner(),
                        ],
                        const SizedBox(height: 18),
                        _buildSummarySection(),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'قائمة طلباتي',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${controller.orders.length} طلبات',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                if (controller.orders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyView(
                      onRefresh: () => controller.loadOrders(isRefresh: true),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: controller.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = controller.orders[index];
                        return OrderCard(
                          order: order,
                          onTap: () => controller.openOrderDetails(order),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'وصّل',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '• مرحباً بك 👋',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'تابع طلباتك بكل سهولة',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: controller.showNotificationsHint,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      children: [
        Expanded(
          child: OrderSummaryCard(
            title: 'إجمالي الطلبات',
            count: controller.totalOrdersCount,
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OrderSummaryCard(
            title: 'الطلبات النشطة',
            count: controller.activeOrdersCount,
            icon: Icons.local_shipping_outlined,
            iconColor: AppColors.warning,
            iconBgColor: AppColors.warningSoft,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OrderSummaryCard(
            title: 'الطلبات المسلمة',
            count: controller.deliveredOrdersCount,
            icon: Icons.check_circle_outline_rounded,
            iconColor: AppColors.success,
            iconBgColor: AppColors.successSoft,
          ),
        ),
      ],
    );
  }
}