import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/orders_repository.dart';

class OrderDetailsController extends GetxController {
  final OrdersRepository repository;

  OrderDetailsController({required this.repository});

  final Rxn<OrderModel> order = Rxn<OrderModel>();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFromCache = false.obs;

  late final String orderId;

  @override
  void onInit() {
    super.onInit();
    orderId = (Get.arguments as String?) ?? (Get.parameters['id'] ?? '');
    loadOrderDetails();
  }

  Future<void> loadOrderDetails() async {
    if (orderId.isEmpty) {
      isLoading.value = false;
      errorMessage.value = 'لم يتم تحديد رقم الطلب.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await repository.fetchOrderById(orderId);
      order.value = result.order;
      isFromCache.value = result.isFromCache;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}