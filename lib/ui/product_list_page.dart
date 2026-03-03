import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';

const String kStudentTitle = 'TH3 - [Triệu Quang Hoàng] - [2351060449]';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _service = ProductService();
  late Future<List<Product>> _futureProducts;
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProducts();
  }

  Future<List<Product>> _loadProducts() {
    return _service.fetchProducts(simulateError: _simulateError);
  }

  void _retry() {
    setState(() {
      _futureProducts = _loadProducts();
    });
  }

  void _toggleSimulatedError() {
    setState(() {
      _simulateError = !_simulateError;
      _futureProducts = _loadProducts();
    });
  }

  Future<void> _openAddProductSheet() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final nameController = TextEditingController();
        final priceController = TextEditingController();
        final descriptionController = TextEditingController();
        final imageUrlController = TextEditingController();
        final unitController = TextEditingController();
        bool inStock = true;
        final formKey = GlobalKey<FormState>();
        bool submitting = false;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              Future<void> submit() async {
                if (submitting) return;
                if (!(formKey.currentState?.validate() ?? false)) return;
                setSheetState(() => submitting = true);
                try {
                  final price = double.tryParse(priceController.text.trim()) ?? 0;
                  await _service.addProduct(
                    Product(
                      id: '',
                      name: nameController.text.trim(),
                      price: price,
                      description: descriptionController.text.trim(),
                      imageUrl: imageUrlController.text.trim(),
                      inStock: inStock,
                      unit: unitController.text.trim(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } finally {
                  setSheetState(() => submitting = false);
                }
              }

              return Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'Thêm sản phẩm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giá (VNĐ)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Nhập giá';
                        return double.tryParse(v.trim()) == null
                            ? 'Giá không hợp lệ'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Ảnh (URL)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Đơn vị',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Còn hàng'),
                        const SizedBox(width: 12),
                        Switch(
                          value: inStock,
                          onChanged: (v) => setSheetState(() => inStock = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: submitting ? null : submit,
                      icon: submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(submitting ? 'Đang lưu...' : 'Lưu sản phẩm'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (created == true) {
      _retry();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm sản phẩm')),
        );
      }
    }
  }

  Future<void> _openEditProductSheet(Product product) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final nameController = TextEditingController(text: product.name);
        final priceController = TextEditingController(
          text: product.price == 0 ? '' : product.price.toString(),
        );
        final descriptionController = TextEditingController(text: product.description);
        final imageUrlController = TextEditingController(text: product.imageUrl);
        final unitController = TextEditingController(text: product.unit);
        bool inStock = product.inStock;
        final formKey = GlobalKey<FormState>();
        bool submitting = false;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              Future<void> submit() async {
                if (submitting) return;
                if (!(formKey.currentState?.validate() ?? false)) return;
                setSheetState(() => submitting = true);
                try {
                  final price = double.tryParse(priceController.text.trim()) ?? 0;
                  await _service.updateProduct(
                    Product(
                      id: product.id,
                      name: nameController.text.trim(),
                      price: price,
                      description: descriptionController.text.trim(),
                      imageUrl: imageUrlController.text.trim(),
                      inStock: inStock,
                      unit: unitController.text.trim(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } finally {
                  setSheetState(() => submitting = false);
                }
              }

              return Form(
                key: formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text(
                      'Sửa sản phẩm',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên sản phẩm',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Nhập tên' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giá (VNĐ)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Nhập giá';
                        return double.tryParse(v.trim()) == null
                            ? 'Giá không hợp lệ'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Ảnh (URL)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Đơn vị (cái, hộp, quyển...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Còn hàng'),
                        const SizedBox(width: 12),
                        Switch(
                          value: inStock,
                          onChanged: (v) => setSheetState(() => inStock = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: submitting ? null : submit,
                      icon: submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(submitting ? 'Đang lưu...' : 'Cập nhật'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (updated == true) {
      _retry();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật sản phẩm')),
        );
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await _service.deleteProduct(productId);
      _retry();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xoá sản phẩm')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<bool> _confirmDelete(Product product) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xoá sản phẩm?'),
            content: Text('Bạn chắc chắn muốn xoá "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xoá'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text(kStudentTitle),
        actions: [
          IconButton(
            tooltip: _simulateError
                ? 'Đang mô phỏng lỗi kết nối'
                : 'Bật mô phỏng lỗi kết nối',
            icon: Icon(
              _simulateError ? Icons.cloud_off : Icons.cloud_queue,
            ),
            onPressed: _toggleSimulatedError,
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ProductFetchException
                ? (snapshot.error as ProductFetchException).message
                : 'Có lỗi xảy ra, vui lòng thử lại.';
            return _ErrorView(
              message: message,
              onRetry: _retry,
            );
          }

          final products = snapshot.data ?? <Product>[];
          if (products.isEmpty) {
            return const _EmptyView();
          }

          return RefreshIndicator(
            onRefresh: () async => _retry(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Dismissible(
                  key: ValueKey(product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                  confirmDismiss: (_) => _confirmDelete(product),
                  onDismissed: (_) => _deleteProduct(product.id),
                  child: InkWell(
                    onTap: () => _openEditProductSheet(product),
                    child: ProductCard(product: product),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProductSheet,
        icon: const Icon(Icons.add),
        label: const Text('Thêm sản phẩm'),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'Chưa có sản phẩm nào',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
