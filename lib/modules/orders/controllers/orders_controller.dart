import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../routes/app_routes.dart';

class OrdersController extends GetxController {
  final OrdersRepository repository;

  OrdersController({required this.repository});

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFromCache = false.obs;

  int get totalOrdersCount => orders.length;

  int get activeOrdersCount =>
      orders.where((order) => order.status.isActive).length;

  int get deliveredOrdersCount =>
      orders.where((order) => order.status == OrderStatus.delivered).length;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final result = await repository.fetchOrders();
      orders.assignAll(result.orders);
      isFromCache.value = result.isFromCache;
    } catch (e) {
      if (orders.isEmpty) {
        errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      } else {
        isFromCache.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void openOrderDetails(OrderModel order) {
    Get.toNamed(AppRoutes.orderDetails, arguments: order.id);
  }

  void showNotificationsHint() {
    Get.snackbar(
      'الإشعارات',
      'لا توجد إشعارات جديدة في الوقت الحالي.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}