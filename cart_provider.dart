import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(Product product, {List<String> toppings = const []}) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) =>
          item.product.id == product.id &&
          _listEquals(item.selectedToppings, toppings),
    );

    if (existingItemIndex >= 0) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(CartItem(
        product: product,
        selectedToppings: toppings,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (quantity <= 0) {
        removeFromCart(index);
      } else {
        _cartItems[index].quantity = quantity;
        notifyListeners();
      }
    }
  }

  void incrementQuantity(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int index) {
    if (index >= 0 && index < _cartItems.length) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        removeFromCart(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
