import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:karyana/productdetails.dart';

import 'categories.dart';
import 'homepage.dart';
import 'main.dart';

class displayProducts extends StatefulWidget {
  final String selectedCategory;

  const displayProducts({required this.selectedCategory, Key? key})
      : super(key: key);

  @override
  State<displayProducts> createState() =>
      _displayProductsState(selectedCategory);
}

class _displayProductsState extends State<displayProducts> {
  String _selectedCategory = '';
  String pageTitle = '';

  _displayProductsState(String selectedCategory) {
    _selectedCategory = selectedCategory;
    if (_selectedCategory == ('')) {
      pageTitle = 'All Products:';
    } else {
      pageTitle = ('$_selectedCategory:');
    }
  }

  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('products');
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(filterProducts);
  }

  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$pageTitle'),
        ),
        backgroundColor: getBackground(context),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      filterProducts();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              if (_searchController.text == '')
                const Text(
                  'Top Selling Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC49000),
                  ),
                ),
              if (_searchController.text == '')
                const SizedBox(
                  height: 10,
                ),
              if (_searchController.text == '')
                Container(
                  child: buildTopSoldProductsCarousel(),
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
                                          builder: (context) =>
                                              ProductDetailsPage(
                                                  product: product,
                                                  cart: mycart),
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
                                              style: const TextStyle(
                                                  fontSize: 18)),
                                          Text('Quantity: ${product.stockQnt}'),
                                          Text('Price: ${product.price}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                  product.stockQnt > 0
                                      ? IconButton(
                                          icon: const Icon(
                                              Icons.add_shopping_cart),
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
        ));
  }

  void filterProducts() {
    String query = _searchController.text.toString();

    _collectionReference
        .where('Name', isGreaterThanOrEqualTo: formatSearchQuery(query))
        .where('Name', isLessThan: '${formatSearchQuery(query)}z')
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        List<Product> searchResults = documents.map((document) {
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

        setState(() {
          filteredProducts = searchResults;
        });
      } else {
        setState(() {
          filteredProducts = [];
        });
      }
    });
  }

  String formatSearchQuery(String query) {
    if (query.isEmpty) {
      return '';
    }

    List<String> words = query.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] =
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }
    return words.join('');
  }

  Widget buildTopSoldProductsCarousel() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('products')
          .orderBy('Sold', descending: true)
          .limit(5)
          .get(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              width: 50, height: 50, child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
            snapshot.data!.docs;

        if (documents.isEmpty) {
          return const Text('No top sold products found');
        }

        return CarouselSlider(
          options: CarouselOptions(
            autoPlayInterval: const Duration(seconds: 1),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: true,
            autoPlay: false,
            height: 145,
            enableInfiniteScroll: true,
            viewportFraction: 0.4,
            initialPage: 0,
            scrollDirection: Axis.horizontal,
          ),
          items: documents.map((doc) {
            final product = Product(
              id: doc.id,
              name: doc['Name'],
              category: doc['Category'],
              stockQnt: doc['Stock qnt'],
              price: doc['Price'],
              pdesc: doc['Pdesc'],
              pic: doc['Pic'],
              sold: doc['Sold'],
            );
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsPage(product: product, cart: mycart),
                  ),
                );
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 105,
                      height: 105,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(product.pic),
                        radius: 40,
                      ),
                    ),
                    Text(product.name),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
