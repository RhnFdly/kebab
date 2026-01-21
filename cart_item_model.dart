import 'product_model.dart';

class CartItem {
  final Product product;
  final List<String> selectedToppings;
  int quantity;
  String? notes;

  CartItem({
    required this.product,
    this.selectedToppings = const [],
    this.quantity = 1,
    this.notes,
  });

  double get totalPrice {
    final toppingPrice = selectedToppings.length * 0.5; // $0.5 per topping
    return (product.price + toppingPrice) * quantity;
  }

  CartItem copyWith({
    Product? product,
    List<String>? selectedToppings,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      selectedToppings: selectedToppings ?? this.selectedToppings,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'product': product.toJson(),
      'selectedToppings': selectedToppings,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      selectedToppings: List<String>.from(json['selectedToppings'] ?? []),
      quantity: json['quantity'] ?? 1,
      notes: json['notes'],
    );
  }
}
