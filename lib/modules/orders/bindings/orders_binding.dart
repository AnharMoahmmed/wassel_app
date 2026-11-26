import 'package:get/get.dart';
import '../../../data/repositories/orders_repository.dart';
import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersRepository>(() => OrdersRepository(), fenix: true);
    Get.lazyPut<OrdersController>(
      () => OrdersController(repository: Get.find<OrdersRepository>()),
    );
  }
}