import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductFetchException implements Exception {
  ProductFetchException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProductService {
  ProductService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Product>> fetchProducts({bool simulateError = false}) async {
    try {
      if (simulateError) {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        throw ProductFetchException('Mất kết nối mô phỏng. Vui lòng thử lại.');
      }

      final snapshot = await _firestore
          .collection('products')
          .orderBy('name')
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs.map(Product.fromDocument).toList();
    } on ProductFetchException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ProductFetchException(
        'Không thể tải danh sách sản phẩm: ${e.message ?? 'Lỗi không xác định'}',
      );
    } catch (_) {
      throw ProductFetchException('Có lỗi ngoài ý muốn. Vui lòng thử lại.');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final data = <String, dynamic>{
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'inStock': product.inStock,
        'unit': product.unit,
      };

      await _firestore.collection('products').doc().set(data);
    } on FirebaseException catch (e) {
      throw ProductFetchException(
        'Không thể thêm sản phẩm: ${e.message ?? 'Lỗi không xác định'}',
      );
    } catch (_) {
      throw ProductFetchException('Có lỗi ngoài ý muốn khi thêm sản phẩm.');
    }
  }

  Future<void> updateProduct(Product product) async {
    if (product.id.isEmpty) {
      throw ProductFetchException('Thiếu ID sản phẩm để cập nhật.');
    }
    try {
      final data = <String, dynamic>{
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'inStock': product.inStock,
        'unit': product.unit,
      };
      await _firestore.collection('products').doc(product.id).update(data);
    } on FirebaseException catch (e) {
      throw ProductFetchException(
        'Không thể cập nhật sản phẩm: ${e.message ?? 'Lỗi không xác định'}',
      );
    } catch (_) {
      throw ProductFetchException('Có lỗi ngoài ý muốn khi cập nhật sản phẩm.');
    }
  }

  Future<void> deleteProduct(String productId) async {
    if (productId.isEmpty) {
      throw ProductFetchException('Thiếu ID sản phẩm để xoá.');
    }
    try {
      await _firestore.collection('products').doc(productId).delete();
    } on FirebaseException catch (e) {
      throw ProductFetchException(
        'Không thể xoá sản phẩm: ${e.message ?? 'Lỗi không xác định'}',
      );
    } catch (_) {
      throw ProductFetchException('Có lỗi ngoài ý muốn khi xoá sản phẩm.');
    }
  }
}
