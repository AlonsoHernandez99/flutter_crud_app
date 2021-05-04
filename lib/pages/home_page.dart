import 'package:bloc_form/bloc/provider.dart';
import 'package:bloc_form/models/product_model.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsBloc = Provider.productsBloc(context);
    productsBloc.loadProducts();
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: _createProductsList(productsBloc),
      floatingActionButton: _createFab(context),
    );
  }

  Widget _createFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Colors.deepPurple,
      onPressed: () => Navigator.pushNamed(context, 'product'),
    );
  }

  Widget _createProductsList(ProductsBloc bloc) {
    return StreamBuilder(
        stream: bloc.productsStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ProductModel>> snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data;
            return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) =>
                    _createItem(context, products[index], bloc));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _createItem(
      BuildContext context, ProductModel product, ProductsBloc bloc) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(color: Colors.redAccent),
      onDismissed: (direction) => bloc.deleteProduct(product.id),
      child: Card(
          child: Column(
        children: [
          product.photoUrl == null
              ? Image(image: AssetImage('assets/no-image.png'))
              : FadeInImage(
                  height: 300.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/loading.gif'),
                  image: NetworkImage(product.photoUrl)),
          ListTile(
            title: Text("${product.title} - ${product.value}"),
            subtitle: Text(product.id),
            onTap: () =>
                Navigator.pushNamed(context, 'product', arguments: product),
          )
        ],
      )),
    );
  }
}
