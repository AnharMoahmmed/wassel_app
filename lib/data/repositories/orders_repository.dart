import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../sample_orders_data.dart';

class OrdersFetchResult {
  final List<OrderModel> orders;
  final bool isFromCache;

  const OrdersFetchResult({
    required this.orders,
    required this.isFromCache,
  });
}

class OrderDetailFetchResult {
  final OrderModel order;
  final bool isFromCache;

  const OrderDetailFetchResult({
    required this.order,
    required this.isFromCache,
  });
}

class OrdersRepository {
  static const String _cacheKey = 'wassel_cached_orders_v1';

  Future<bool> _hasInternetConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<void> _saveToCache(List<OrderModel> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
  }

  Future<List<OrderModel>?> _readFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrdersFetchResult> fetchOrders() async {
    await Future.delayed(const Duration(milliseconds: 650));

    final isOnline = await _hasInternetConnection();
    if (!isOnline) {
      final cached = await _readFromCache();
      if (cached != null) {
        return OrdersFetchResult(orders: cached, isFromCache: true);
      }
      throw Exception('لا يوجد اتصال بالإنترنت ولا تتوفر بيانات محفوظة.');
    }

    try {
      // يمكن استبدال SampleOrdersData بطلب HTTP حقيقي لاحقاً
      final freshOrders = SampleOrdersData.orders;
      await _saveToCache(freshOrders);
      return OrdersFetchResult(orders: freshOrders, isFromCache: false);
    } catch (_) {
      final cached = await _readFromCache();
      if (cached != null) {
        return OrdersFetchResult(orders: cached, isFromCache: true);
      }
      rethrow;
    }
  }

  Future<OrderDetailFetchResult> fetchOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final isOnline = await _hasInternetConnection();
    if (!isOnline) {
      final cached = await _readFromCache();
      if (cached != null) {
        final match = cached.where((o) => o.id == orderId).firstOrNull;
        if (match != null) {
          return OrderDetailFetchResult(order: match, isFromCache: true);
        }
      }
      throw Exception('تعذر تحميل تفاصيل الطلب دون اتصال بالإنترنت.');
    }

    final freshOrders = SampleOrdersData.orders;
    await _saveToCache(freshOrders);
    final match = freshOrders.where((o) => o.id == orderId).firstOrNull;
    if (match == null) {
      throw Exception('الطلب رقم #$orderId غير موجود.');
    }
    return OrderDetailFetchResult(order: match, isFromCache: false);
  }
}