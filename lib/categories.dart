import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';
import 'main.dart';
import 'productdetails.dart';
import 'products.dart';

class Product {
  String id;
  String name;
  String category;
  int stockQnt;
  double price;
  String pdesc;
  String pic;
  int quantity;
  int sold;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.stockQnt,
    required this.price,
    required this.pdesc,
    required this.pic,
    required this.sold,
  }) : quantity = 0;
}

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('products');
  String _selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();

    return Scaffold(
      backgroundColor: getBackground(context),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC49000),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CarouselSlider(
            options: CarouselOptions(
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.easeInOut,
              enlargeCenterPage: true,
              autoPlay: true,
              height: 145,
              enableInfiniteScroll: true,
              viewportFraction: 0.4,
              initialPage: 0,
              scrollDirection: Axis.horizontal,
            ),
            items: [
              buildCategoryButton('', 'All Products'),
              buildCategoryButton('Home Essentials', 'Home Essentials'),
              buildCategoryButton('Food', 'Food'),
              buildCategoryButton('Home Decor', 'Home Decor'),
              buildCategoryButton('Health and Wellness', 'Health & Wellness'),
              buildCategoryButton('Sports and Fitness', 'Sports & Fitness'),
              buildCategoryButton('Toiletries', 'Toiletries'),
              buildCategoryButton('Clothing', 'Clothing'),
              buildCategoryButton('Footwear', 'Footwear'),
              buildCategoryButton('Toys and Games', 'Toys & Games'),
              buildCategoryButton('Appliances', 'Appliances'),
              buildCategoryButton('Electronics', 'Electronics'),
              buildCategoryButton('Utensils', 'Utensils'),
              buildCategoryButton('Outdoor Essentials', 'Outdoor Essentials'),
            ],
          ),
          const Text(
            'All Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC49000),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory.isNotEmpty
                  ? _collectionReference
                      .where('Category', isEqualTo: _selectedCategory)
                      .snapshots()
                  : _collectionReference.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Product> filteredProducts = [];
                List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                if (_searchController.text.isEmpty) {
                  filteredProducts = documents.map((document) {
                    Map<String, dynamic> productData =
                        document.data() as Map<String, dynamic>;
                    return Product(
                      id: document.id,
                      name: productData['Name'],
                      category: productData['Category'],
                      stockQnt: productData['Stock qnt'],
                      price: productData['Price'],
                      pdesc: productData['Pdesc'],
                      pic: productData['Pic'],
                      sold: productData['Sold'],
                    );
                  }).toList();
                }
                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    Product product = filteredProducts[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: getBorder(context)),
                          color: getBorderBG(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                          product: product, cart: mycart),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    child: Image.network(product.pic),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          style: const TextStyle(fontSize: 18)),
                                      Text('Quantity: ${product.stockQnt}'),
                                      Text('Price: ${product.price}'),
                                    ],
                                  ),
                                ),
                              ),
                              product.stockQnt > 0
                                  ? IconButton(
                                      icon: const Icon(Icons.add_shopping_cart),
                                      onPressed: () {
                                        _collectionReference
                                            .doc(product.id)
                                            .update({
                                          'Stock qnt': product.stockQnt - 1,
                                        });
                                        mycart.addToCart(product);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryButton(String value, String label) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('categories')
          .where('Name', isEqualTo: label)
          .get(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
            snapshot.data!.docs;

        if (documents.isEmpty) {
          return const Text('Category not found');
        }

        final categoryData = documents.first.data();
        if (categoryData is Map<String, dynamic>) {
          final name = categoryData['Name'] as String?;
          final imageUrl = categoryData['Pic'] as String?;
          if (name == null || imageUrl == null) {
            return const Text(
                'Invalid category data: Missing name or imageUrl');
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                _selectedCategory = value;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => displayProducts(
                            selectedCategory: _selectedCategory)));
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 105,
                      height: 105,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 45,
                      ),
                    ),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Text('Invalid category data');
        }
      },
    );
  }
}

/*class ProductSearchDelegate extends SearchDelegate<String> {
  final CollectionReference _collectionReference =
  FirebaseFirestore.instance.collection('products');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _collectionReference
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThan: query + 'z')
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
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
              return ListTile(
                title: Text(product.name),
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
                              FavoritesPage favorites = FavoritesPage();
                              favorites.addToFavorites(product.id);
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Add to Cart'),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .runTransaction((transaction) async {
                                DocumentSnapshot freshSnap =
                                await transaction.get(documents[index].reference);
                                Product freshProduct = Product(
                                  id: freshSnap.id,
                                  name: freshSnap['Name'],
                                  category: freshSnap['Category'],
                                  stockQnt: freshSnap['Stock qnt'],
                                  price: freshSnap['Price'],
                                  pdesc: freshSnap['Pdesc'],
                                  pic: freshSnap['Pic'],
                                );
                                if (freshProduct.stockQnt > 0) {
                                  transaction.update(documents[index].reference, {
                                    'Stock qnt': freshProduct.stockQnt - 1,
                                  });
                                  mycart.addToCart(freshProduct);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to cart'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Out of Stock'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              });
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
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
*/
