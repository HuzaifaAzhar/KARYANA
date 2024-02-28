import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:karyana/main.dart';
import 'categories.dart';
import 'favorites.dart';
import 'cart.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final Cart cart;

  const ProductDetailsPage({required this.product, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //elevation: 0,
        //backgroundColor: Colors.blueGrey[900],
      ),

      body: Container(
        //color: Colors.black87, // Dark background color
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC49000), // Glow-in-the-dark gold color
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 18,
                        //color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.pdesc,
                      style: const TextStyle(
                        fontSize: 16,
                        //color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quantity: ${product.stockQnt}',
                      style: const TextStyle(
                        fontSize: 16,
                        //color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Price: ${product.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        //color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sold: ${product.sold}',
                      style: const TextStyle(
                        fontSize: 16,
                        //color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    product.pic,
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              FavoritesPage favorites = FavoritesPage();
              favorites.addToFavorites(product.id);
              showSnackbar(context, 'Added To Favorites');
              Navigator.pop(context);
            },
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            child: const Icon(Icons.favorite_border_outlined),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              if (product.stockQnt == 0) {
                showSnackbar(context, 'Out of Stock');
              } else {
                final CollectionReference _collectionReference = FirebaseFirestore.instance.collection('products');
                _collectionReference.doc(product.id).update({
                  'Stock qnt': product.stockQnt - 1,
                });
                cart.addToCart(product);
                showSnackbar(context, 'Added To Cart');
                Navigator.pop(context);
              }
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_shopping_cart_outlined),
          ),
        ],
      ),
    );
  }
}
