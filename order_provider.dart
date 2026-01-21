import 'package:flutter/foundation.dart';
import '../models/order_model.dart' as model;
import '../models/order_model.dart' show OrderStatus;
import '../models/cart_item_model.dart';
import '../services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Place a new order and save it to Firestore
  Future<bool> placeOrder({
    required String userId,
    required List<CartItem> items,
    required String address,
    required String phoneNumber,
    required String paymentMethod,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final totalPrice = items.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

      final order = model.Order(
        id: '',
        userId: userId,
        items: items,
        totalPrice: totalPrice,
        address: address,
        phoneNumber: phoneNumber,
        paymentMethod: paymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      final orderId = await _firestoreService.createOrder(order);
      
      if (orderId != null && orderId.isNotEmpty) {
        return true;
      }
      _errorMessage = 'Failed to create order';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print('Error placing order: $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
