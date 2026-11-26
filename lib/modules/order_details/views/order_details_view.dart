import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _copyText(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ $label إلى الحافظة',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      backgroundColor: AppColors.textPrimary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const SafeArea(
            child: AppLoadingView(message: 'جاري تحميل تفاصيل الطلب...'),
          );
        }

        if (controller.errorMessage.value.isNotEmpty ||
            controller.order.value == null) {
          return SafeArea(
            child: Column(
              children: [
                _buildFallbackAppBar(),
                Expanded(
                  child: AppErrorView(
                    message: controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'تعذر العثور على تفاصيل الطلب.',
                    onRetry: controller.loadOrderDetails,
                  ),
                ),
              ],
            ),
          );
        }

        final order = controller.order.value!;
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.loadOrderDetails,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildModernAppBar(order),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (controller.isFromCache.value) ...[
                      const OfflineBanner(),
                      const SizedBox(height: 14),
                    ],
                    _animatedSection(
                      delayMs: 0,
                      child: _buildHeroStatusCard(order),
                    ),
                    const SizedBox(height: 16),
                    _animatedSection(
                      delayMs: 70,
                      child: _buildSectionCard(
                        title: 'تتبع مسار التوصيل',
                        subtitle: 'تحديثات مباشرة لحالة طلبك',
                        icon: Icons.route_rounded,
                        accentColor: AppColors.primary,
                        accentBg: AppColors.secondary,
                        child: OrderTrackingTimeline(order: order),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _animatedSection(
                      delayMs: 140,
                      child: _buildItemsSection(order),
                    ),
                    const SizedBox(height: 16),
                    _animatedSection(
                      delayMs: 210,
                      child: _buildAddressSection(order),
                    ),
                    const SizedBox(height: 16),
                    _animatedSection(
                      delayMs: 280,
                      child: _buildPaymentSummarySection(order),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFallbackAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      ),
      title: const Text('تفاصيل الطلب'),
    );
  }

  SliverAppBar _buildModernAppBar(OrderModel order) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      toolbarHeight: 68,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: Get.back,
            borderRadius: BorderRadius.circular(12),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل الطلب',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'وصّل • متابعة الطلب',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _copyText('#${order.id}', 'رقم الطلب'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatusCard(OrderModel order) {
    final statusColor = order.status.textColor;
    final isCancelled = order.status == OrderStatus.cancelled;
    final currentStep = order.status.timelineStageIndex;
    final double progress = isCancelled
        ? 0.0
        : order.status == OrderStatus.delivered
            ? 1.0
            : (currentStep + 1) / 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isCancelled
              ? [const Color(0xFF991B1B), AppColors.error]
              : [const Color(0xFF1A43A3), AppColors.primary, const Color(0xFF3B76F6)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isCancelled ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Icon(
                  order.status.icon,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة الطلب الحالية',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.status.labelAr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: OrderStatusBadge(
                  status: order.status,
                  showIcon: false,
                ),
              ),
            ],
          ),
          if (!isCancelled) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'نسبة التقدم في التوصيل',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
              ),
            ),
            child: Column(
              children: [
                _heroMetaRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'تاريخ الطلب',
                  value: AppFormatters.formatDateTime(order.createdAt),
                ),
                if (order.estimatedDeliveryAt != null && !isCancelled) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  _heroMetaRow(
                    icon: Icons.bolt_rounded,
                    label: 'التوصيل المتوقع',
                    value: AppFormatters.formatDateTime(
                      order.estimatedDeliveryAt!,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCancelled) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'يمكنك التواصل مع خدمة عملاء وصّل لأي استفسار.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'طلب مضمون مع وصّل',
                style: TextStyle(
                  color: statusColor == AppColors.success
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroMetaRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(OrderModel order) {
    final List<Color> tileAccents = [
      AppColors.primary,
      const Color(0xFF0EA5E9),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      AppColors.warning,
    ];

    return _buildSectionCard(
      title: 'محتويات الطلب',
      subtitle: '${order.items.length} منتجات في هذا الطلب',
      icon: Icons.shopping_bag_rounded,
      accentColor: const Color(0xFF7C3AED),
      accentBg: const Color(0xFFF3E8FF),
      child: Column(
        children: List.generate(order.items.length, (index) {
          final item = order.items[index];
          final accent = tileAccents[index % tileAccents.length];
          final isLast = index == order.items.length - 1;

          return Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: item.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                item.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.inventory_2_rounded,
                                  color: accent,
                                  size: 24,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.inventory_2_rounded,
                              color: accent,
                              size: 24,
                            ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '×${item.qty}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                        'سعر الوحدة: ${AppFormatters.formatCurrency(item.price)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    AppFormatters.formatCurrency(item.total),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddressSection(OrderModel order) {
    return _buildSectionCard(
      title: 'بيانات المستلم والعنوان',
      subtitle: 'نقطة تسليم الطلب',
      icon: Icons.location_on_rounded,
      accentColor: const Color(0xFF0D9488),
      accentBg: const Color(0xFFCCFBF1),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDFA), Color(0xFFEAF2FF)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF0D9488).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.place_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'عنوان التوصيل الكامل',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.address,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _miniContactTile(
                  icon: Icons.person_rounded,
                  label: 'المستلم',
                  value: order.customer,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _copyText(order.phone, 'رقم الهاتف'),
                  borderRadius: BorderRadius.circular(14),
                  child: _miniContactTile(
                    icon: Icons.phone_rounded,
                    label: 'رقم الهاتف (انسخ)',
                    value: order.phone,
                    iconColor: AppColors.success,
                    isPhone: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniContactTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isPhone = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: isPhone ? TextDirection.ltr : null,
            textAlign: isPhone ? TextAlign.right : TextAlign.start,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummarySection(OrderModel order) {
    return _buildSectionCard(
      title: 'ملخص الدفع',
      subtitle: 'تفاصيل الفاتورة بالريال اليمني',
      icon: Icons.receipt_long_rounded,
      accentColor: AppColors.warning,
      accentBg: AppColors.warningSoft,
      child: Column(
        children: [
          _priceRow(
            'المجموع الفرعي',
            AppFormatters.formatCurrency(order.subtotal),
          ),
          const SizedBox(height: 10),
          _priceRow(
            'رسوم التوصيل',
            order.deliveryFee == 0
                ? 'مجاني'
                : AppFormatters.formatCurrency(order.deliveryFee),
            valueColor: order.deliveryFee == 0 ? AppColors.success : null,
          ),
          if (order.tax > 0) ...[
            const SizedBox(height: 10),
            _priceRow('الضريبة', AppFormatters.formatCurrency(order.tax)),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, Color(0xFFDCE8FF)],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.payments_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'الإجمالي النهائي',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  AppFormatters.formatCurrency(order.total),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Color accentBg,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _animatedSection({required int delayMs, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + delayMs),
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