import 'dart:convert';
import 'dart:io';

import 'package:bloc_form/models/product_model.dart';
import 'package:bloc_form/shared_preferences/user_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';

class ProductProvider {
  final String _url = "https://flutter-apps-a593f-default-rtdb.firebaseio.com";
  final _prefs = new UserPreferences();

  Future<bool> createProduct(ProductModel product) async {
    final url = Uri.parse('$_url/products.json?auth=${_prefs.token}');

    final resp = await http.post(url, body: productModelToJson(product));
    json.decode(resp.body);
    return true;
  }

  Future<bool> editProduct(ProductModel product) async {
    final url =
        Uri.parse('$_url/products/${product.id}.json?auth=${_prefs.token}');

    final resp = await http.put(url, body: productModelToJson(product));
    json.decode(resp.body);
    return true;
  }

  Future<List<ProductModel>> loadProducts() async {
    final url = Uri.parse('$_url/products.json?auth=${_prefs.token}');
    final resp = await http.get(url);

    final Map<String, dynamic> decodedData = json.decode(resp.body);
    final List<ProductModel> products = [];
    if (decodedData == null) return [];

    decodedData.forEach((id, product) {
      final productTmp = ProductModel.fromJson(product);
      productTmp.id = id;
      products.add(productTmp);
    });

    return products;
  }

  Future<int> deleteProduct(String id) async {
    final url = Uri.parse('$_url/products/$id.json?auth=${_prefs.token}');
    await http.delete(url);
    return 1;
  }

  Future<String> uploadImage(File image) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/daftbkaqo/image/upload?upload_preset=teqxke4h');
    final mimeType = mime(image.path).split('/');

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));
    imageUploadRequest.files.add(file);

    final streamResonse = await imageUploadRequest.send();

    final resp = await http.Response.fromStream(streamResonse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print("Error in upload image: ${resp.body}");
      return null;
    }
    final responseData = json.decode(resp.body);

    return responseData["secure_url"];
  }
}
