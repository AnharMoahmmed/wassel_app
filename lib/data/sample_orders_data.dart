import 'models/order_model.dart';

/// بيانات تجريبية واقعية لشركة «وصّل» تغطي جميع الحالات الخمس المطلوبة
class SampleOrdersData {
  SampleOrdersData._();

  static List<OrderModel> get orders => [
        OrderModel(
          id: 'WS-1040',
          customer: 'محمد الحميري',
          phone: '+967 771 000 000',
          address: 'صنعاء، شارع حدة - جولة المصباحي، عمارة النخيل',
          deliveryFee: 1500,
          createdAt: DateTime(2026, 11, 1, 8, 0),
          estimatedDeliveryAt: DateTime(2026, 11, 1, 13, 30),
          status: OrderStatus.processing,
          items: const [
            OrderItemModel(name: 'رز بسمتي 10 كيلو', qty: 1, price: 18000),
            OrderItemModel(name: 'زيت طبخ 1.8 لتر', qty: 2, price: 4200),
            OrderItemModel(name: 'معكرونة (6 حبات)', qty: 3, price: 2700),
          ],
          timeline: [
            OrderTimelineRecord(
              step: 'تم استلام الطلب',
              at: DateTime(2026, 11, 1, 8, 0),
            ),
          ],
        ),
        OrderModel(
          id: 'WS-1041',
          customer: 'سارة المقطري',
          phone: '+967 771 012 333',
          address: 'صنعاء، الحصبة - جوار سوق الحصبة المركزي',
          deliveryFee: 1500,
          createdAt: DateTime(2026, 11, 2, 11, 20),
          estimatedDeliveryAt: DateTime(2026, 11, 2, 16, 0),
          status: OrderStatus.confirmed,
          items: const [
            OrderItemModel(name: 'حليب نيدو 900 جرام', qty: 1, price: 9800),
            OrderItemModel(name: 'عسل سدر حضرمي 500 جرام', qty: 2, price: 22000),
            OrderItemModel(name: 'قهوة يمنية 250 جرام', qty: 2, price: 5200),
          ],
          timeline: [
            OrderTimelineRecord(
              step: 'تم استلام الطلب',
              at: DateTime(2026, 11, 2, 11, 20),
            ),
            OrderTimelineRecord(
              step: 'تم تأكيد الطلب',
              at: DateTime(2026, 11, 2, 11, 45),
            ),
          ],
        ),
        OrderModel(
          id: 'WS-1042',
          customer: 'فاطمة العريقي',
          phone: '+967 771 004 111',
          address: 'صنعاء، الأصبحي - شارع المقالح، حي السلام',
          deliveryFee: 1500,
          createdAt: DateTime(2026, 11, 3, 9, 7),
          estimatedDeliveryAt: DateTime(2026, 11, 3, 12, 30),
          status: OrderStatus.outForDelivery,
          items: const [
            OrderItemModel(name: 'زيت طبخ 1.8 لتر', qty: 2, price: 4200),
            OrderItemModel(name: 'شاهي 450 جرام', qty: 3, price: 3100),
            OrderItemModel(name: 'تونة (4 علب)', qty: 2, price: 3600),
          ],
          timeline: [
            OrderTimelineRecord(
              step: 'تم استلام الطلب',
              at: DateTime(2026, 11, 3, 9, 7),
            ),
            OrderTimelineRecord(
              step: 'تم تأكيد الطلب',
              at: DateTime(2026, 11, 3, 9, 25),
            ),
            OrderTimelineRecord(
              step: 'جاري تجهيز الطلب',
              at: DateTime(2026, 11, 3, 9, 50),
            ),
            OrderTimelineRecord(
              step: 'خرج الطلب للتوصيل',
              at: DateTime(2026, 11, 3, 10, 15),
            ),
          ],
        ),
        OrderModel(
          id: 'WS-1043',
          customer: 'عبدالله الشامي',
          phone: '+967 771 008 222',
          address: 'صنعاء، شارع الستين الغربي - قرب مستشفى آزال',
          deliveryFee: 1500,
          createdAt: DateTime(2026, 11, 4, 10, 14),
          estimatedDeliveryAt: DateTime(2026, 11, 4, 13, 0),
          status: OrderStatus.delivered,
          items: const [
            OrderItemModel(name: 'سكر 5 كيلو', qty: 3, price: 6500),
            OrderItemModel(name: 'دقيق 10 كيلو', qty: 1, price: 9500),
          ],
          timeline: [
            OrderTimelineRecord(
              step: 'تم استلام الطلب',
              at: DateTime(2026, 11, 4, 10, 14),
            ),
            OrderTimelineRecord(
              step: 'تم تأكيد الطلب',
              at: DateTime(2026, 11, 4, 10, 30),
            ),
            OrderTimelineRecord(
              step: 'جاري تجهيز الطلب',
              at: DateTime(2026, 11, 4, 10, 55),
            ),
            OrderTimelineRecord(
              step: 'خرج الطلب للتوصيل',
              at: DateTime(2026, 11, 4, 11, 14),
            ),
            OrderTimelineRecord(
              step: 'تم تسليم الطلب',
              at: DateTime(2026, 11, 4, 12, 14),
            ),
          ],
        ),
        OrderModel(
          id: 'WS-1044',
          customer: 'خالد العولقي',
          phone: '+967 771 024 666',
          address: 'صنعاء، شميلة - شارع تعز، بجانب بريد شميلة',
          deliveryFee: 1500,
          createdAt: DateTime(2026, 11, 5, 14, 42),
          status: OrderStatus.cancelled,
          items: const [
            OrderItemModel(name: 'تونة (4 علب)', qty: 1, price: 3600),
            OrderItemModel(name: 'قهوة يمنية 250 جرام', qty: 2, price: 5200),
          ],
          timeline: [
            OrderTimelineRecord(
              step: 'تم استلام الطلب',
              at: DateTime(2026, 11, 5, 14, 42),
            ),
          ],
        ),
        OrderModel(
          id: 'WS-1045',
          customer: 'نورة الأغبري',
          phone: '+967 771 020 555',
          address: 'صنعاء، بيت بوس - الحي الدبلوماسي',
          deliveryFee: 1500,
          createdAt: DateTime(2026, 11, 6, 13, 35),
          estimatedDeliveryAt: DateTime(2026, 11, 6, 16, 30),
          status: OrderStatus.delivered,
          items: const [
            OrderItemModel(name: 'معكرونة (6 حبات)', qty: 3, price: 2700),
            OrderItemModel(name: 'رز بسمتي 10 كيلو', qty: 1, price: 18000),
          ],
          timeline: [
            OrderTimelineRecord(
              step: 'تم استلام الطلب',
              at: DateTime(2026, 11, 6, 13, 35),
            ),
            OrderTimelineRecord(
              step: 'تم تأكيد الطلب',
              at: DateTime(2026, 11, 6, 13, 50),
            ),
            OrderTimelineRecord(
              step: 'جاري تجهيز الطلب',
              at: DateTime(2026, 11, 6, 14, 10),
            ),
            OrderTimelineRecord(
              step: 'خرج الطلب للتوصيل',
              at: DateTime(2026, 11, 6, 14, 35),
            ),
            OrderTimelineRecord(
              step: 'تم تسليم الطلب',
              at: DateTime(2026, 11, 6, 15, 35),
            ),
          ],
        ),
      ];
}