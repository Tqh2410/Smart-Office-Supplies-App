import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final bool inStock;
  final String unit;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.inStock,
    required this.unit,
  });

  factory Product.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawPrice = data['price'];
    return Product(
      id: doc.id,
      name: (data['name'] as String?)?.trim() ?? 'Chưa có tên',
      price: rawPrice is num ? rawPrice.toDouble() : 0,
      description: (data['description'] as String?)?.trim() ?? 'Không có mô tả',
      imageUrl: (data['imageUrl'] as String?)?.trim() ?? '',
      inStock: data['inStock'] is bool ? data['inStock'] as bool : true,
      unit: (data['unit'] as String?)?.trim() ?? '',
    );
  }
}
