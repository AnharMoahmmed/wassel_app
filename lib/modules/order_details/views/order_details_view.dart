import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../widgets/offline_banner.dart';
import '../../../widgets/order_status_badge.dart';
import '../../../widgets/order_tracking_timeline.dart';
import '../../../widgets/state_views.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsView extends GetView<OrderDetailsController> {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Obx(() {
          final idText = controller.order.value?.id ?? controller.orderId;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تفاصيل الطلب',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (idText.isNotEmpty)
                Text(
                  '#$idText',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingView(message: 'جاري تحميل تفاصيل الطلب...');
        }

        if (controller.errorMessage.value.isNotEmpty ||
            controller.order.value == null) {
          return AppErrorView(
            message: controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'تعذر العثور على تفاصيل الطلب.',
            onRetry: controller.loadOrderDetails,
          );
        }

        final order = controller.order.value!;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadOrderDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isFromCache.value) ...[
                  const OfflineBanner(),
                  const SizedBox(height: 14),
                ],
                _buildStatusSection(order),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'تتبع حالة التوصيل',
                  icon: Icons.timeline_rounded,
                  child: OrderTrackingTimeline(order: order),
                ),
                const SizedBox(height: 16),
                _buildItemsSection(order),
                const SizedBox(height: 16),
                _buildAddressSection(order),
                const SizedBox(height: 16),
                _buildPaymentSummarySection(order),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusSection(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'حالة الطلب الحالية',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ الطلب',
            value: AppFormatters.formatDateTime(order.createdAt),
          ),
          if (order.estimatedDeliveryAt != null &&
              order.status != OrderStatus.cancelled) ...[
            const SizedBox(height: 10),
            _infoRow(
              icon: Icons.schedule_rounded,
              label: 'التوصيل المتوقع',
              value: AppFormatters.formatDateTime(order.estimatedDeliveryAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSection(OrderModel order) {
    return _buildSectionCard(
      title: 'المنتجات (${order.items.length})',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: List.generate(order.items.length, (index) {
          final item = order.items[index];
          final isLast = index == order.items.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الكمية: ${item.qty}  ×  ${AppFormatters.formatCurrency(item.price)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppFormatters.formatCurrency(item.total),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order) {
    return _buildSectionCard(
      title: 'عنوان التوصيل',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            icon: Icons.person_outline_rounded,
            label: 'اسم المستلم',
            value: order.customer,
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.phone_outlined,
            label: 'رقم الهاتف',
            value: order.phone,
            isPhone: true,
          ),
          const SizedBox(height: 10),
          _infoRow(
            icon: Icons.place_outlined,
            label: 'العنوان الكامل',
            value: order.address,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummarySection(OrderModel order) {
    return _buildSectionCard(
      title: 'ملخص الدفع',
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _priceRow('المجموع الفرعي', AppFormatters.formatCurrency(order.subtotal)),
          const SizedBox(height: 10),
          _priceRow(
            'رسوم التوصيل',
            AppFormatters.formatCurrency(order.deliveryFee),
          ),
          if (order.tax > 0) ...[
            const SizedBox(height: 10),
            _priceRow('الضريبة', AppFormatters.formatCurrency(order.tax)),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الإجمالي النهائي',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(order.total),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPhone = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textDirection: isPhone ? TextDirection.ltr : null,
            textAlign: isPhone ? TextAlign.right : TextAlign.start,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
}