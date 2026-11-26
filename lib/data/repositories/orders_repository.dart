import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

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
  static const String _assetPath = 'assets/orders.json';

  Future<bool> _hasInternetConnection() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  Future<List<OrderModel>> _loadOrdersFromJsonAsset() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(jsonString);

    final List<dynamic> rawList;
    if (decoded is Map<String, dynamic>) {
      rawList = decoded['orders'] as List<dynamic>? ?? [];
    } else if (decoded is List<dynamic>) {
      rawList = decoded;
    } else {
      throw Exception('تنسيق ملف JSON غير صالح.');
    }

    return rawList
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
    await Future.delayed(const Duration(milliseconds: 500));

    final isOnline = await _hasInternetConnection();
    if (!isOnline) {
      final cached = await _readFromCache();
      if (cached != null) {
        return OrdersFetchResult(orders: cached, isFromCache: true);
      }
      throw Exception('لا يوجد اتصال بالإنترنت ولا تتوفر بيانات محفوظة.');
    }

    try {
      final freshOrders = await _loadOrdersFromJsonAsset();
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
    await Future.delayed(const Duration(milliseconds: 250));

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

    try {
      final freshOrders = await _loadOrdersFromJsonAsset();
      await _saveToCache(freshOrders);
      final match = freshOrders.where((o) => o.id == orderId).firstOrNull;
      if (match == null) {
        throw Exception('الطلب رقم #$orderId غير موجود.');
      }
      return OrderDetailFetchResult(order: match, isFromCache: false);
    } catch (_) {
      final cached = await _readFromCache();
      if (cached != null) {
        final match = cached.where((o) => o.id == orderId).firstOrNull;
        if (match != null) {
          return OrderDetailFetchResult(order: match, isFromCache: true);
        }
      }
      rethrow;
    }
  }
}