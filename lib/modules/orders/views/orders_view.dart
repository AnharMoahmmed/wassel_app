import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../widgets/offline_banner.dart';
import '../../../widgets/order_card.dart';
import '../../../widgets/order_status_badge.dart';
import '../../../widgets/order_summary_card.dart';
import '../../../widgets/state_views.dart';
import '../controllers/orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  OrderModel? get _spotlightOrder {
    final outForDelivery = controller.orders
        .where((o) => o.status == OrderStatus.outForDelivery)
        .firstOrNull;
    if (outForDelivery != null) return outForDelivery;
    return controller.orders.where((o) => o.status.isActive).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: _buildModernHeader(),
            ),
            Expanded(
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

                final spotlight = _spotlightOrder;

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => controller.loadOrders(isRefresh: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (controller.isFromCache.value) ...[
                                const OfflineBanner(),
                                const SizedBox(height: 14),
                              ],
                              _buildSummarySection(),
                              if (spotlight != null) ...[
                                const SizedBox(height: 16),
                                _buildActiveSpotlight(spotlight),
                              ],
                              const SizedBox(height: 22),
                              _buildSectionHeader(),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      if (controller.orders.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppEmptyView(
                            onRefresh: () =>
                                controller.loadOrders(isRefresh: true),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          sliver: SliverList.separated(
                            itemCount: controller.orders.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = controller.orders[index];
                              return _animatedItem(
                                index: index,
                                child: OrderCard(
                                  order: order,
                                  onTap: () =>
                                      controller.openOrderDetails(order),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1A43A3),
            AppColors.primary,
            Color(0xFF3B76F6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              left: -24,
              top: -28,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: 36,
              bottom: -36,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'وصّل',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'مرحباً بك 👋',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'تابع طلباتك بكل سهولة وفي أي وقت',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: controller.showNotificationsHint,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            Positioned(
                              top: 10,
                              right: 11,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            icon: Icons.local_shipping_rounded,
            iconColor: AppColors.warning,
            iconBgColor: AppColors.warningSoft,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OrderSummaryCard(
            title: 'تم تسليمها',
            count: controller.deliveredOrdersCount,
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
            iconBgColor: AppColors.successSoft,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSpotlight(OrderModel order) {
    final isOutForDelivery = order.status == OrderStatus.outForDelivery;
    final accent = isOutForDelivery ? AppColors.primary : AppColors.warning;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => controller.openOrderDetails(order),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                accent.withValues(alpha: 0.08),
                AppColors.surface,
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  order.status.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOutForDelivery
                              ? 'طلبك في الطريق إليك'
                              : 'تتبع طلبك النشط',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '#${order.id}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.address} • ${AppFormatters.formatCurrency(order.total)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusBadge(status: order.status, showIcon: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(
              Icons.inventory_2_rounded,
              size: 19,
              color: AppColors.primary,
            ),
            SizedBox(width: 7),
            Text(
              'قائمة طلباتي',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${controller.orders.length} طلبات',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _animatedItem({required int index, required Widget child}) {
    final delay = (index.clamp(0, 6)) * 55;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, widgetChild) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: widgetChild,
          ),
        );
      },
      child: child,
    );
  }
}