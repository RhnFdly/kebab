import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ApiService {
  // Base URL - mudah diganti untuk production
  static const String baseUrl = 'https://api.example.com/kebab-hub';
  
  // Untuk development, bisa menggunakan Mock API atau localhost
  // static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor untuk logging (opsional)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // Mock Data - digunakan jika API belum tersedia
  Future<List<Product>> getProducts() async {
    try {
      // Coba fetch dari API terlebih dahulu
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products');
    } catch (e) {
      // Fallback ke mock data jika API error
      return _getMockProducts();
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'category': category,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load products by category');
    } catch (e) {
      return _getMockProducts()
          .where((product) => product.category == category)
          .toList();
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        return List<String>.from(response.data);
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      // Fallback ke mock categories
      return ['All', 'Classic', 'Spicy', 'Cheese', 'Premium'];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      }
      throw Exception('Failed to load product');
    } catch (e) {
      // Fallback ke mock product
      final products = _getMockProducts();
      return products.firstWhere(
        (product) => product.id == id,
        orElse: () => products.first,
      );
    }
  }

  // Mock Products Data
  List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Classic Chicken Kebab',
        description:
            'Tender chicken marinated in special spices, wrapped in warm pita bread with fresh vegetables and our signature sauce.',
        price: 12.99,
        imageUrl:
            'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=500',
        category: 'Classic',
        toppings: ['Lettuce', 'Tomato', 'Onion', 'Pickles', 'Garlic Sauce'],
        rating: 4.5,
        reviewCount: 120,
      ),
      Product(
        id: '2',
        name: 'Spicy Lamb Kebab',
        description:
            'Succulent lamb with spicy marinade, served with hot sauce and fresh vegetables.',
        price: 15.99,
        imageUrl:
            'https://images.unsplash.com/photo-1615873968403-89e068629265?w=500',
        category: 'Spicy',
        toppings: ['Lettuce', 'Tomato', 'Onion', 'Spicy Sauce', 'Jalapenos'],
        rating: 4.7,
        reviewCount: 89,
      ),
      Product(
        id: '3',
        name: 'Cheese Kebab Deluxe',
        description:
            'Premium kebab with melted cheese, grilled vegetables, and our special cheese sauce.',
        price: 16.99,
        imageUrl:
            'https://images.unsplash.com/photo-1579168765467-3b235f938439?w=500',
        category: 'Cheese',
        toppings: ['Cheese', 'Lettuce', 'Tomato', 'Cheese Sauce', 'Bell Peppers'],
        rating: 4.8,
        reviewCount: 156,
      ),
      Product(
        id: '4',
        name: 'Premium Mixed Kebab',
        description:
            'A combination of chicken and lamb with all premium toppings and special sauces.',
        price: 18.99,
        imageUrl:
            'https://images.unsplash.com/photo-1608039829573-8e6139396439?w=500',
        category: 'Premium',
        toppings: [
          'Lettuce',
          'Tomato',
          'Onion',
          'Pickles',
          'Garlic Sauce',
          'Tahini',
          'Fries'
        ],
        rating: 4.9,
        reviewCount: 203,
      ),
      Product(
        id: '5',
        name: 'Veggie Kebab',
        description:
            'Fresh grilled vegetables with hummus and tahini sauce, perfect for vegetarians.',
        price: 10.99,
        imageUrl:
            'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=500',
        category: 'Classic',
        toppings: ['Lettuce', 'Tomato', 'Cucumber', 'Hummus', 'Tahini'],
        rating: 4.4,
        reviewCount: 67,
      ),
      Product(
        id: '6',
        name: 'BBQ Chicken Kebab',
        description:
            'Grilled chicken with BBQ sauce, caramelized onions, and special seasoning.',
        price: 13.99,
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
        category: 'Spicy',
        toppings: ['Lettuce', 'Tomato', 'Onion', 'BBQ Sauce', 'Pickles'],
        rating: 4.6,
        reviewCount: 134,
      ),
    ];
  }
}
