import 'package:cloud_firestore/cloud_firestore.dart';
// Menambahkan 'as model' untuk menghindari konflik nama class Order
import '../models/order_model.dart' as model;
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Profile
  Future<void> saveUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Orders
  // Menggunakan model.Order agar merujuk ke order_model.dart
  Future<String> createOrder(model.Order order) async {
    final docRef = await _firestore.collection('orders').add(order.toJson());
    return docRef.id;
  }

  Future<List<model.Order>> getUserOrders(String userId) async {
    try {
      if (userId.isEmpty) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => model.Order.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  Future<model.Order?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (doc.exists) {
      return model.Order.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    }
    return null;
  }

  Stream<List<model.Order>> streamUserOrders(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => model.Order.fromJson({
                      'id': doc.id,
                      ...doc.data(),
                    }))
                .toList();
          } catch (e) {
            print('Error parsing order stream: $e');
            return <model.Order>[];
          }
        })
        .handleError((e) {
          print('Stream error fetching orders: $e');
        });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}