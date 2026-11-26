# wassel_app


## 📱 Project Overview

Customers frequently contact the delivery company to ask about their order status. Wassel solves this problem by providing a simple mobile interface where customers can independently view their orders and track delivery progress.

A key feature of the application is its **offline-first experience**, allowing customers to access previously saved order information even when their internet connection is weak or unavailable.

## ✨ Features

### 1. Orders List – قائمة الطلبات
- View all customer orders.
- Display order number, date, total amount, and status.
- Order status indicators with distinct colors.
- Summary of total, active, and delivered orders.
- Pull-to-refresh functionality.
- Loading, error, and empty states.

### 2. Order Details – تفاصيل الطلب
- View complete order information.
- Display purchased products, quantities, and prices.
- Show recipient and delivery address information.
- Display payment breakdown and total amount.
- Visual delivery tracking timeline.
- Track each stage from order confirmation to delivery.

### 3. Offline Support – العمل بدون إنترنت
- Save the latest successfully retrieved orders locally.
- Display cached orders when the internet is unavailable.
- Show an offline indicator to inform users that displayed data may not be up to date.
- Preserve previously cached data if a network request fails.

### 4. Arabic & RTL Support
- Fully Arabic user interface.
- Right-to-Left layout.
- Arabic labels, messages, and order statuses.
- Yemeni Riyal (ر.ي) currency formatting.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile development |
| Dart | Programming language |
| GetX | State management and navigation |
| Dio | HTTP client and API requests |
| GetStorage | Local data persistence |
| connectivity_plus | Network connectivity monitoring |
| Material 3 | UI components and design system |

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── bindings/
│   ├── routes/
│   └── theme/
│
├── core/
│   ├── constants/
│   ├── services/
│   ├── storage/
│   ├── utils/
│   └── widgets/
│
├── data/
│   ├── models/
│   ├── providers/
│   └── repositories/
│
├── modules/
│   ├── orders/
│   │   ├── bindings/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── widgets/
│   │
│   └── order_details/
│       ├── bindings/
│       ├── controllers/
│       ├── views/
│       └── widgets/
│
└── main.dart

assets/
└── data/
    └── orders.json
```

---


## 🎨 Application Screens

### Orders List – قائمة الطلبات
Displays customer orders with their status, date, and total amount.

### Order Details – تفاصيل الطلب
Displays order items, delivery information, payment summary, and delivery progress.

---

## 🚀 Future Improvements

- Real-time order tracking.
- Push notifications for order status changes.
- Google Maps integration.
- Customer authentication.
- Multi-language support.
- Improved background synchronization.

---


**Framework:** Flutter  
**State Management:** GetX  
**Language:** Dart  
**Platform:** Android

---