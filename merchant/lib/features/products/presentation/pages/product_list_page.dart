import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductBloc>().add(
                const LoadProducts(refresh: true),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: state.isOffline ? Colors.orange : Colors.red,
              ),
            );
          } else if (state is SyncCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Products synced successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductLoading && state is! ProductsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductsLoaded) {
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent * 0.9) {
                  context.read<ProductBloc>().add(const LoadMoreProducts());
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductBloc>().add(
                    const LoadProducts(refresh: true),
                  );
                },
                child: state.products.isEmpty
                    ? const Center(child: Text('No products available'))
                    : ListView.builder(
                        itemCount:
                            state.products.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.products.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final product = state.products[index];
                          return _ProductListItem(
                            product: product,
                            productBloc: context.read<ProductBloc>(),
                          );
                        },
                      ),
              ),
            );
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.isOffline ? Icons.cloud_off : Icons.error,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        const LoadProducts(refresh: true),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Welcome'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );

          if (result == true && context.mounted) {
            context.read<ProductBloc>().add(const LoadProducts(refresh: true));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final Product product;
  final ProductBloc productBloc;

  const _ProductListItem({required this.product, required this.productBloc});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: product.imageUrl != null
            ? Image.network(
                product.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
              )
            : const Icon(Icons.inventory),
        title: Row(
          children: [
            Expanded(child: Text(product.name)),
            if (!product.isSynced)
              const Icon(Icons.sync_disabled, size: 16, color: Colors.orange),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Text('Stock: ${product.stock}'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(productId: product.id),
            ),
          );

          if (result == true) {
            productBloc.add(const LoadProducts(refresh: true));
          }
        },
      ),
    );
  }
}
