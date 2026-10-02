import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/domain/models/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/domain/models/order_model.dart';

void main() {
  group('Cart & Order Regression Tests', () {
    test('CartModel safely parses string numbers and nulls', () {
      final json = {
        'id': 1,
        'customer_id': 10,
        'cart_group_id': 'group_1',
        'product_id': 100,
        'product_type': 'physical',
        'price': '150.50',
        'discount': '10.0',
        'tax': '7.5',
        'quantity': '2',
        'is_checked': 1,
      };

      final cart = CartModel.fromJson(json);
      expect(cart.id, equals(1));
      expect(cart.price, equals(150.50));
      expect(cart.discount, equals(10.0));
      expect(cart.tax, equals(7.5));
      expect(cart.quantity, equals(2));
      expect(cart.isChecked, isTrue);
    });

    test('OrderModel safely parses null and empty numerical fields', () {
      final json = {
        'total_size': '5',
        'limit': '10',
        'offset': '1',
        'orders': [
          {
            'id': 5001,
            'customer_id': 10,
            'customer_type': 'customer',
            'payment_status': 'unpaid',
            'order_status': 'pending',
            'payment_method': 'cash_on_delivery',
            'order_amount': '2500.0',
            'discount_amount': null,
            'shipping_cost': null,
            'extra_discount': null,
          }
        ]
      };

      final orderModel = OrderModel.fromJson(json);
      expect(orderModel.totalSize, equals(5));
      expect(orderModel.orders!.length, equals(1));
      expect(orderModel.orders![0].orderAmount, equals(2500.0));
      expect(orderModel.orders![0].discountAmount, equals(0.0));
      expect(orderModel.orders![0].shippingCost, equals(0.0));
      expect(orderModel.orders![0].extraDiscount, equals(0.0));
    });
  });
}
