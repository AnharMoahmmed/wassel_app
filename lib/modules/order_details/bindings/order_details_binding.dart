import 'package:get/get.dart';
import '../../../data/repositories/orders_repository.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersRepository>(() => OrdersRepository(), fenix: true);
    Get.lazyPut<OrderDetailsController>(
      () => OrderDetailsController(repository: Get.find<OrdersRepository>()),
    );
  }
}