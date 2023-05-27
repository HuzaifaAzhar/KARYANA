import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'favorites.dart';

class Product {
  String id; // Add an ID field to uniquely identify each product
  String name;
  String category;
  int stockQnt;
  double price;
  String pdesc;
  String pic;
  int quantity;
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.stockQnt,
    required this.price,
    required this.pdesc,
    required this.pic,
  }): quantity = 0;
}

class ProductListPage extends StatelessWidget {
  final CollectionReference _collectionReference =
  FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _collectionReference.snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic>? productData =
              documents[index].data() as Map<String, dynamic>?;
              if (productData == null) {
                return const SizedBox.shrink();
              }
              Product product = Product(
                id: documents[index].id,
                name: productData['Name'],
                category: productData['Category'],
                stockQnt: productData['Stock qnt'],
                price: productData['Price'],
                pdesc: productData['Pdesc'],
                pic: productData['Pic'],
              );
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(product.name),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 200,
                                    child: Image.network(product.pic, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 16),
                                  Text('Category: ${product.category}'),
                                  Text('Stock: ${product.stockQnt}'),
                                  Text('Price: ${product.price}'),
                                  Text('Description: ${product.pdesc}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Add to Favorites'),
                                  onPressed: () {
                                    FavoritesPage.addToFavorites(product.id);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(product.pic),
                      ),
                    ),
                    // SizedBox(
                    //   width: 100,
                    //   height: 100,
                    //   child: Image.network(product.pic),
                    // ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: const TextStyle(fontSize: 18)),
                            //Text(product.category),
                            Text('Quantity: ${product.stockQnt}'),
                            Text('Price: ${product.price}'),
                            //Text(product.pdesc),
                          ],
                        ),
                      ),
                    ),
                    product.stockQnt > 0 // Check if the stock is available
                        ? IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () {
                        // Reduce the stock by 1 and update the database
                        _collectionReference.doc(product.id).update({
                          'Stock qnt': product.stockQnt - 1,
                        });
                        mycart.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to cart'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    )
                        : const Text(
                      'Out of Stock',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
