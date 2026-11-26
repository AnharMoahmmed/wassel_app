import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum OrderStatus {
  processing,
  confirmed,
  outForDelivery,
  delivered,
  cancelled;

  String get labelAr {
    switch (this) {
      case OrderStatus.processing:
        return 'قيد المعالجة';
      case OrderStatus.confirmed:
        return 'تم تأكيد الطلب';
      case OrderStatus.outForDelivery:
        return 'جاري التوصيل';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  bool get isActive =>
      this == OrderStatus.processing ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.outForDelivery;

  Color get textColor {
    switch (this) {
      case OrderStatus.processing:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.outForDelivery:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case OrderStatus.processing:
        return AppColors.warningSoft;
      case OrderStatus.confirmed:
        return AppColors.infoSoft;
      case OrderStatus.outForDelivery:
        return AppColors.secondary;
      case OrderStatus.delivered:
        return AppColors.successSoft;
      case OrderStatus.cancelled:
        return AppColors.errorSoft;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.processing:
        return Icons.hourglass_top_rounded;
      case OrderStatus.confirmed:
        return Icons.verified_rounded;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  /// رقم المرحلة الحالية في الخط الزمني المكون من 5 خطوات (0..4)
  int get timelineStageIndex {
    switch (this) {
      case OrderStatus.processing:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'processing':
      case 'new':
        return OrderStatus.processing;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'out_for_delivery':
      case 'on_the_way':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }

  String toApiString() {
    switch (this) {
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}

class OrderItemModel {
  final String name;
  final int qty;
  final int price;
  final String? imageUrl;

  const OrderItemModel({
    required this.name,
    required this.qty,
    required this.price,
    this.imageUrl,
  });

  int get total => qty * price;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'price': price,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}

class OrderTimelineRecord {
  final String step;
  final DateTime? at;

  const OrderTimelineRecord({
    required this.step,
    this.at,
  });

  factory OrderTimelineRecord.fromJson(Map<String, dynamic> json) {
    return OrderTimelineRecord(
      step: json['step'] as String? ?? '',
      at: json['at'] != null ? DateTime.tryParse(json['at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'step': step,
        'at': at?.toIso8601String(),
      };
}

class OrderModel {
  final String id;
  final String customer;
  final String phone;
  final String address;
  final int deliveryFee;
  final int tax;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryAt;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final List<OrderTimelineRecord> timeline;

  const OrderModel({
    required this.id,
    required this.customer,
    required this.phone,
    required this.address,
    required this.deliveryFee,
    this.tax = 0,
    required this.createdAt,
    this.estimatedDeliveryAt,
    required this.status,
    required this.items,
    required this.timeline,
  });

  int get subtotal => items.fold(0, (sum, item) => sum + item.total);

  int get total => subtotal + deliveryFee + tax;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      customer: json['customer'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      deliveryFee: (json['delivery_fee'] as num?)?.toInt() ?? 0,
      tax: (json['tax'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      estimatedDeliveryAt: json['estimated_delivery_at'] != null
          ? DateTime.tryParse(json['estimated_delivery_at'] as String)
          : null,
      status: OrderStatus.fromString(json['status'] as String? ?? 'processing'),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeline: (json['timeline'] as List<dynamic>? ?? [])
          .map((e) => OrderTimelineRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'phone': phone,
        'address': address,
        'delivery_fee': deliveryFee,
        'tax': tax,
        'created_at': createdAt.toIso8601String(),
        'estimated_delivery_at': estimatedDeliveryAt?.toIso8601String(),
        'status': status.toApiString(),
        'items': items.map((e) => e.toJson()).toList(),
        'timeline': timeline.map((e) => e.toJson()).toList(),
      };
}