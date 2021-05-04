import 'dart:io';

import 'package:bloc_form/models/product_model.dart';
import 'package:bloc_form/providers/product_provider.dart';
import 'package:rxdart/subjects.dart';

class ProductsBloc {
  final _productsController = new BehaviorSubject<List<ProductModel>>();
  final _loadingController = new BehaviorSubject<bool>();

  final _productProvider = new ProductProvider();

  disposed() {
    _productsController?.close();
    _loadingController?.close();
  }

  Stream<List<ProductModel>> get productsStream => _productsController.stream;
  Stream<bool> get loading => _loadingController.stream;

  void loadProducts() async {
    final products = await _productProvider.loadProducts();
    _productsController..sink.add(products);
  }

  void createProduct(ProductModel product) async {
    _loadingController.sink.add(true);
    await _productProvider.createProduct(product);
    _loadingController.sink.add(false);
    loadProducts();
  }

  Future<String> uploadPhoto(File file) async {
    _loadingController.sink.add(true);
    final photoUrl = await _productProvider.uploadImage(file);
    _loadingController.sink.add(false);

    return photoUrl;
  }

  void updateProduct(ProductModel product) async {
    _loadingController.sink.add(true);
    await _productProvider.editProduct(product);
    _loadingController.sink.add(false);
    loadProducts();
  }

  void deleteProduct(String productId) async {
    await _productProvider.deleteProduct(productId);
  }
}
