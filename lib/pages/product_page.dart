import 'dart:io';

import 'package:bloc_form/bloc/provider.dart';
import 'package:bloc_form/models/product_model.dart';
import 'package:bloc_form/utils/utils.dart' as utils;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final formKey = GlobalKey<FormState>();

  ProductModel product = new ProductModel();
  bool _saving = false;
  PickedFile _photo;

  ProductsBloc _productsBloc;

  @override
  Widget build(BuildContext context) {
    _productsBloc = Provider.productsBloc(context);
    final ProductModel productArg = ModalRoute.of(context).settings.arguments;
    if (productArg != null) {
      product = productArg;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: () => _processImage(ImageSource.gallery),
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () => _processImage(ImageSource.camera),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(15.0),
            child: Form(
                key: formKey,
                child: Column(children: [
                  _showPhoto(),
                  _createName(),
                  _createPrice(),
                  _createAvailable(),
                  _createButton()
                ]))),
      ),
    );
  }

  Widget _createName() {
    return TextFormField(
      initialValue: product.title,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Product'),
      onSaved: (value) => product.title = value,
      validator: (value) {
        if (value.length < 3) {
          return 'Product name must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _createPrice() {
    return TextFormField(
        initialValue: product.value.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Product'),
        onSaved: (value) => product.value = double.parse(value),
        validator: (value) {
          if (utils.isNumeric(value)) {
            return null;
          }
          return 'Only numbers';
        });
  }

  Widget _createButton() {
    // ignore: deprecated_member_use
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.deepPurple,
      textColor: Colors.white,
      icon: Icon(Icons.save),
      onPressed: (_saving) ? null : _submit,
      label: Text('Save'),
    );
  }

  void _submit() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      setState(() {
        _saving = true;
      });

      if (_photo != null) {
        final File file = File(_photo.path);
        product.photoUrl = await _productsBloc.uploadPhoto(file);
      }

      if (product.id == null)
        _productsBloc.createProduct(product);
      else
        _productsBloc.updateProduct(product);

      _showSnackbar('Sucessfull operation');
      setState(() {
        _saving = false;
      });
      Navigator.pop(context, "home");
    } else {
      return;
    }
  }

  Widget _createAvailable() {
    return SwitchListTile(
        value: product.available,
        title: Text('Available'),
        activeColor: Colors.deepPurple,
        onChanged: (value) => setState(() {
              product.available = value;
            }));
  }

  void _showSnackbar(String message) {
    final snackbar = SnackBar(
        content: Text(message), duration: Duration(milliseconds: 1500));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Widget _showPhoto() {
    if (product.photoUrl != null) {
      return FadeInImage(
          image: NetworkImage(product.photoUrl),
          placeholder: AssetImage('assets/loading.gif'),
          height: 300.0,
          fit: BoxFit.contain);
    }
    {
      if (_photo != null) {
        final File file = File(_photo.path);

        return Image.file(
          file,
          fit: BoxFit.cover,
          height: 300.0,
        );
      }
      return Image.asset('assets/no-image.png');
    }
  }

  _processImage(ImageSource source) async {
    final _picker = ImagePicker();
    _photo = await _picker.getImage(source: source);

    setState(() {
      if (_photo != null) {
        product.photoUrl = null;
      }
    });
  }
}
