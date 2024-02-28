import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'productdetails.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'products.dart';
import 'main.dart';

class Product {
  String id; // Add an ID field to uniquely identify each product
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
  }): quantity = 0;
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFFC49000),),
                        ),
                    ),
                              const SizedBox(height: 10,),
                                  CarouselSlider(
                                  options: CarouselOptions(
                                    autoPlayInterval: const Duration(seconds: 3),
                                    autoPlayAnimationDuration: const Duration(milliseconds: 800),  // Adjust the animation duration as needed
                                    autoPlayCurve: Curves.easeInOut,  // Adjust the animation curve as needed
                                    enlargeCenterPage: true,
                                    autoPlay: true,
                                    height: 145, // Adjust the height as needed
                                    enableInfiniteScroll: true, // Enable infinite scrolling
                                    viewportFraction: 0.4, // Adjust the fraction to control the number of visible categories
                                    initialPage: 0, // Set the initial page index
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFFC49000),),
                              ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory.isNotEmpty
                  ? _collectionReference
                  .where('Category', isEqualTo: _selectedCategory)
                  .snapshots()
                  : _collectionReference.snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                      builder: (context) => ProductDetailsPage(product: product, cart: mycart),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name, style: const TextStyle(fontSize: 18)),
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
          return const CircleAvatar(backgroundColor: Colors.transparent,child: CircularProgressIndicator(),);
        }

        if (snapshot.hasError) {
          // If an error occurred while fetching the data, you can handle it here.
          return Text('Error: ${snapshot.error}');
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
            snapshot.data!.docs;

        if (documents.isEmpty) {
          // Handle the case when no category with the given name is found.
          return const Text('Category not found');
        }

        final categoryData = documents.first.data();
        if (categoryData is Map<String, dynamic>) {
          final name = categoryData['Name'] as String?;
          final imageUrl = categoryData['Pic'] as String?;
          if (name == null || imageUrl == null) {
            // Handle the case when the name or imageUrl is null.
            return const Text('Invalid category data: Missing name or imageUrl');
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                _selectedCategory = value;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) =>
                            displayProducts(selectedCategory: _selectedCategory)));
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
          // Print categoryData for debugging purposes
          return const Text('Invalid category data');
        }
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'homepage.dart';
// import 'productdetails.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'products.dart';
//
// class Product {
//   String id; // Add an ID field to uniquely identify each product
//   String name;
//   String category;
//   int stockQnt;
//   double price;
//   String pdesc;
//   String pic;
//   int quantity;
//   int sold;
//   Product({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.stockQnt,
//     required this.price,
//     required this.pdesc,
//     required this.pic,
//     this.sold=0,
//   }) : quantity = 0;
// }
//
//
// class ProductListPage extends StatefulWidget {
//   const ProductListPage({super.key});
//
//   @override
//   _ProductListPageState createState() => _ProductListPageState();
// }
//
// class _ProductListPageState extends State<ProductListPage> {
//   final CollectionReference _collectionReference =
//   FirebaseFirestore.instance.collection('products');
//   String _selectedCategory = '';
//   List<Product> filteredProducts = [];
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Container(
//             constraints: const BoxConstraints.expand(),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 16,),
//                       const Text(
//                         'Categories',
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                               const SizedBox(height: 10,),
//                                   CarouselSlider(
//                                   options: CarouselOptions(
//                                     autoPlayInterval: const Duration(seconds: 1),
//                                     autoPlayAnimationDuration: const Duration(milliseconds: 800),  // Adjust the animation duration as needed
//                                     autoPlayCurve: Curves.easeInOut,  // Adjust the animation curve as needed
//                                     enlargeCenterPage: true,
//                                     autoPlay: true,
//                                     height: 150, // Adjust the height as needed
//                                     enableInfiniteScroll: true, // Enable infinite scrolling
//                                     viewportFraction: 0.4, // Adjust the fraction to control the number of visible categories
//                                     initialPage: 0, // Set the initial page index
//                                     scrollDirection: Axis.horizontal,
//                                   ),
//                                   items: [
//                                     buildCategoryButton('', 'All Products'),
//                                     buildCategoryButton('Home Essentials', 'Home Essentials'),
//                                     buildCategoryButton('Food', 'Food'),
//                                     buildCategoryButton('Home Decor', 'Home Decor'),
//                                     buildCategoryButton('Health and Wellness', 'Health & Wellness'),
//                                     buildCategoryButton('Sports and Fitness', 'Sports & Fitness'),
//                                     buildCategoryButton('Toiletries', 'Toiletries'),
//                                     buildCategoryButton('Clothing', 'Clothing'),
//                                     buildCategoryButton('Footwear', 'Footwear'),
//                                     buildCategoryButton('Toys and Games', 'Toys & Games'),
//                                     buildCategoryButton('Appliances', 'Appliances'),
//                                     buildCategoryButton('Electronics', 'Electronics'),
//                                     buildCategoryButton('Utensils', 'Utensils'),
//                                     buildCategoryButton('Outdoor Essentials', 'Outdoor Essentials'),
//                                   ],
//                                 ),
//                               const Text(
//                                 'All Products',
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                       buildAllProducts(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//     );
//   }
//
//   Widget buildAllProducts() {
//     return Expanded(
//       child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//         stream: _collectionReference.snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           }
//           final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
//               snapshot.data!.docs;
//
//           if (documents.isEmpty) {
//             // Handle the case when no products are available
//             return const Text('No products found');
//           }
//
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (BuildContext context, int index) {
//               final productData = documents[index].data();
//               if (productData is Map<String, dynamic>) {
//                 final id = documents[index].id;
//                 final name = productData['Name'] as String?;
//                 final category = productData['Category'] as String?;
//                 final stockQnt = productData['Stock Qnt'] as int?;
//                 final price = productData['Price'] as double?;
//                 final pdesc = productData['Pdesc'] as String?;
//                 final pic = productData['Pic'] as String?;
//
//                 if (name == null ||
//                     category == null ||
//                     stockQnt == null ||
//                     price == null ||
//                     pdesc == null ||
//                     pic == null) {
//                   // Handle the case when any required field is missing
//                   return const Text('Invalid product data: Missing required field');
//                 }
//
//                 final product = Product(
//                   id: id,
//                   name: name,
//                   category: category,
//                   stockQnt: stockQnt,
//                   price: price,
//                   pdesc: pdesc,
//                   pic: pic,
//                 );
//
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (ctx) => ProductDetailsPage(product: product, cart: mycart,),
//                       ),
//                     );
//                   },
//                   child: ListTile(
//                     leading: Image.network(
//                       product.pic,
//                       width: 50,
//                       height: 50,
//                       fit: BoxFit.cover,
//                     ),
//                     title: Text(product.name),
//                     subtitle: Text(product.category),
//                   ),
//                 );
//               } else {
//                 // Print productData for debugging purposes
//                 return const Text('Invalid product data');
//               }
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget buildCategoryButton(String value, String label) {
//     return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
//       future: FirebaseFirestore.instance
//           .collection('categories')
//           .where('Name', isEqualTo: label)
//           .get(),
//       builder: (BuildContext context,
//           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox(width:50,height:50,child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasError) {
//           // If an error occurred while fetching the data, you can handle it here.
//           return Text('Error: ${snapshot.error}');
//         }
//
//         final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
//             snapshot.data!.docs;
//
//         if (documents.isEmpty) {
//           // Handle the case when no category with the given name is found.
//           return const Text('Category not found');
//         }
//
//         final categoryData = documents.first.data();
//         if (categoryData is Map<String, dynamic>) {
//           final name = categoryData['Name'] as String?;
//           final imageUrl = categoryData['Pic'] as String?;
//
//           if (name == null || imageUrl == null) {
//             // Handle the case when the name or imageUrl is null.
//             return const Text('Invalid category data: Missing name or imageUrl');
//           }
//
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: GestureDetector(
//               onTap: () {
//                 _selectedCategory = value;
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (ctx) =>
//                             displayProducts(selectedCategory: _selectedCategory)));
//               },
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 100,
//                       height: 100,
//                       child: Image.network(
//                         imageUrl,
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     Text(
//                       label,
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         } else {
//           // Print categoryData for debugging purposes
//           return const Text('Invalid category data');
//         }
//       },
//     );
//   }
//
//
//








// void filterProducts() {
  //   String query = _searchController.text.toLowerCase();
  //   _collectionReference.get().then((QuerySnapshot querySnapshot) {
  //     List<Product> allProducts = querySnapshot.docs.map((document) {
  //       Map<String, dynamic> productData =
  //       document.data() as Map<String, dynamic>;
  //       return Product(
  //         id: document.id,
  //         name: productData['Name'],
  //         category: productData['Category'],
  //         stockQnt: productData['Stock qnt'],
  //         price: productData['Price'],
  //         pdesc: productData['Pdesc'],
  //         pic: productData['Pic'],
  //       );
  //     }).toList();
  //     setState(() {
  //       filteredProducts = allProducts.where((product) {
  //         String productName = product.name.toLowerCase();
  //         return productName.contains(query);
  //       }).toList();
  //     });
  //   });
  // }
//}




// class ProductDetailsPage extends StatelessWidget {
//   final Product product;
//
//   const ProductDetailsPage({Key? key, required this.product})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(product.name),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Image.network(
//                 product.pic,
//                 width: 200,
//                 height: 200,
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             Text('Category: ${product.category}'),
//             Text('Quantity: ${product.stockQnt}'),
//             Text('Price: ${product.price}'),
//             const SizedBox(height: 16.0),
//             Text('Description:'),
//             Text(product.pdesc),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:karyana/favorites.dart';
// import 'homepage.dart';
// import 'productdetails.dart';
//
// class Product {
//   String id; // Add an ID field to uniquely identify each product
//   String name;
//   String category;
//   int stockQnt;
//   double price;
//   String pdesc;
//   String pic;
//   int quantity;
//   Product({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.stockQnt,
//     required this.price,
//     required this.pdesc,
//     required this.pic,
//   }): quantity = 0;
// }
//
//
//
// class ProductListPage extends StatefulWidget {
//   @override
//   _ProductListPageState createState() => _ProductListPageState();
// }
//
//
//
// class _ProductListPageState extends State<ProductListPage> {
//   final CollectionReference _collectionReference =
//   FirebaseFirestore.instance.collection('products');
//   String _selectedCategory = '';
//
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController _searchController = TextEditingController();
//
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               // Add padding around the search bar
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               // Use a Material design search bar
//               child: TextField(
//                 onTap: () {
//                   // Perform search when the search bar is tapped
//                   showSearch(
//                     context: context,
//                     delegate: ProductSearchDelegate(),
//                   );
//                 },
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search...',
//                   // Add a clear button to the search bar
//                   // suffixIcon: IconButton(
//                   //   icon: Icon(Icons.clear),
//                   //   onPressed: () => _searchController.clear(),
//                   // ),
//                   suffixIcon: PopupMenuButton<String>(
//                     onSelected: (category) {
//                       // Filter by category
//                       setState(() {
//                         _selectedCategory = category;
//                       });
//                     },
//                     itemBuilder: (BuildContext context) {
//                       // Create category filter menu items
//                       return [
//                         PopupMenuItem<String>(
//                           value: '', // Empty string represents all categories
//                           child: Text('All Categories'),
//                         ),
//                         PopupMenuItem<String>(
//                           value: 'Home Decor',
//                           child: Text('Category 1'),
//                         ),
//                         PopupMenuItem<String>(
//                           value: 'Category 2',
//                           child: Text('Category 2'),
//                         ),
//                         PopupMenuItem<String>(
//                           value: 'Category 3',
//                           child: Text('Category 3'),
//                         ),
//                       ];
//                     },
//                   ),
//                   // Add a search icon or button to the search bar
//                   prefixIcon: IconButton(
//                     icon: Icon(Icons.search),
//                     onPressed: () {
//                       // Perform the search here
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _selectedCategory.isNotEmpty
//                   ? _collectionReference
//                   .where('Category', isEqualTo: _selectedCategory)
//                   .snapshots()
//                   : _collectionReference.snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasError) {
//                   return const Text('Something went wrong');
//                 }
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: documents.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     Map<String, dynamic>? productData =
//                     documents[index].data() as Map<String, dynamic>?;
//                     if (productData == null) {
//                       return const SizedBox.shrink();
//                     }
//
//                     Product product = Product(
//                       id: documents[index].id,
//                       name: productData['Name'],
//                       category: productData['Category'],
//                       stockQnt: productData['Stock qnt'],
//                       price: productData['Price'],
//                       pdesc: productData['Pdesc'],
//                       pic: productData['Pic'],
//                     );
//
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ProductDetailsPage(product: product),
//                                 ),
//                               );
//                             },
//                             child: SizedBox(
//                               width: 100,
//                               height: 100,
//                               child: Image.network(product.pic),
//                             ),
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(product.name,
//                                       style: const TextStyle(fontSize: 18)),
//                                   //Text(product.category),
//                                   Text('Quantity: ${product.stockQnt}'),
//                                   Text('Price: ${product.price}'),
//                                   //Text(product.pdesc),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           product.stockQnt > 0 // Check if the stock is available
//                               ? IconButton(
//                             icon: const Icon(Icons.add_shopping_cart),
//                             onPressed: () {
//                               // Reduce the stock by 1 and update the database
//                               _collectionReference.doc(product.id).update({
//                                 'Stock qnt': product.stockQnt - 1,
//                               });
//                               mycart.addToCart(product);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Added to cart'),
//                                   duration: Duration(seconds: 2),
//                                 ),
//                               );
//                             },
//                           )
//                               : const Text(
//                             'Out of Stock',
//                             style: TextStyle(color: Colors.red),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// class ProductSearchDelegate extends SearchDelegate<String> {
//   final CollectionReference _collectionReference =
//   FirebaseFirestore.instance.collection('products');
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     return FutureBuilder<QuerySnapshot>(
//       future: _collectionReference
//           .where('Name', isGreaterThanOrEqualTo: query)
//           .where('Name', isLessThan: query + 'z')
//           .get(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasData) {
//           List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (BuildContext context, int index) {
//               Map<String, dynamic>? productData =
//               documents[index].data() as Map<String, dynamic>?;
//               if (productData == null) {
//                 return const SizedBox.shrink();
//               }
//               Product product = Product(
//                 id: documents[index].id,
//                 name: productData['Name'],
//                 category: productData['Category'],
//                 stockQnt: productData['Stock qnt'],
//                 price: productData['Price'],
//                 pdesc: productData['Pdesc'],
//                 pic: productData['Pic'],
//               );
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 ProductDetailsPage(product: product),
//                           ),
//                         );
//                       },
//                       child: SizedBox(
//                         width: 100,
//                         height: 100,
//                         child: Image.network(product.pic),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(product.name,
//                                 style: const TextStyle(fontSize: 18)),
//                             //Text(product.category),
//                             Text('Quantity: ${product.stockQnt}'),
//                             Text('Price: ${product.price}'),
//                             //Text(product.pdesc),
//                           ],
//                         ),
//                       ),
//                     ),
//                     product.stockQnt > 0 // Check if the stock is available
//                         ? IconButton(
//                       icon: const Icon(Icons.add_shopping_cart),
//                       onPressed: () {
//                         // Reduce the stock by 1 and update the database
//                         _collectionReference.doc(product.id).update({
//                           'Stock qnt': product.stockQnt - 1,
//                         });
//                         mycart.addToCart(product);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Added to cart'),
//                             duration: Duration(seconds: 2),
//                           ),
//                         );
//                       },
//                     )
//                         : const Text(
//                       'Out of Stock',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return FutureBuilder<QuerySnapshot>(
//       future: _collectionReference
//           .where('Name', isGreaterThanOrEqualTo: formatSearchQuery(query))
//           .where('Name', isLessThan: formatSearchQuery(query) + 'z')
//           .get(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasData) {
//           List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (BuildContext context, int index) {
//               Map<String, dynamic>? productData =
//               documents[index].data() as Map<String, dynamic>?;
//               if (productData == null) {
//                 return const SizedBox.shrink();
//               }
//               Product product = Product(
//                 id: documents[index].id,
//                 name: productData['Name'],
//                 category: productData['Category'],
//                 stockQnt: productData['Stock qnt'],
//                 price: productData['Price'],
//                 pdesc: productData['Pdesc'],
//                 pic: productData['Pic'],
//               );
//               return ListTile(
//                 title: Text(product.name),
//                 onTap: () {
//                   query = product.name; // Set the selected suggestion as the query
//                   showResults(context); // Show the search results
//                 },
//               );
//             },
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
//
//   String formatSearchQuery(String query) {
//     if (query.isEmpty) {
//       return '';
//     }
//
//     List<String> words = query.split(' ');
//     for (int i = 0; i < words.length; i++) {
//       if (words[i].isNotEmpty) {
//         words[i] = words[i][0].toUpperCase() +
//             words[i].substring(1).toLowerCase();
//       }
//     }
//     return words.join(' ');
//   }
//
// }



//class _ProductListPageState extends State<ProductListPage> {
//   final CollectionReference _collectionReference =
//   FirebaseFirestore.instance.collection('products');
//   String _selectedCategory = '';
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     // Open search dialog
//                     showSearch(
//                       context: context,
//                       delegate: ProductSearchDelegate(),
//                     );
//                   },
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (category) {
//                     // Filter by category
//                     setState(() {
//                       _selectedCategory = category;
//                     });
//                   },
//                   itemBuilder: (BuildContext context) {
//                     // Create category filter menu items
//                     return [
//                       PopupMenuItem<String>(
//                         value: '', // Empty string represents all categories
//                         child: Text('All Categories'),
//                       ),
//                       PopupMenuItem<String>(
//                         value: 'Category 1',
//                         child: Text('Category 1'),
//                       ),
//                       PopupMenuItem<String>(
//                         value: 'Category 2',
//                         child: Text('Category 2'),
//                       ),
//                       PopupMenuItem<String>(
//                         value: 'Category 3',
//                         child: Text('Category 3'),
//                       ),
//                     ];
//                   },
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _selectedCategory.isNotEmpty
//                   ? _collectionReference
//                   .where('Category', isEqualTo: _selectedCategory)
//                   .snapshots()
//                   : _collectionReference.snapshots(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 if (snapshot.hasError) {
//                   return const Text('Something went wrong');
//                 }
//
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: documents.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     Map<String, dynamic>? productData =
//                     documents[index].data() as Map<String, dynamic>?;
//                     if (productData == null) {
//                       return const SizedBox.shrink();
//                     }
//
//                     Product product = Product(
//                       id: documents[index].id,
//                       name: productData['Name'],
//                       category: productData['Category'],
//                       stockQnt: productData['Stock qnt'],
//                       price: productData['Price'],
//                       pdesc: productData['Pdesc'],
//                       pic: productData['Pic'],
//                     );
//
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ProductDetailsPage(product: product),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               // Replace with your desired widget for displaying the product
//                               child: Text(product.name),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



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
    return Container(); // Replace with the desired search results widget
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



// class ProductSearchDelegate extends SearchDelegate<String> {
//   final CollectionReference _collectionReference =
//   FirebaseFirestore.instance.collection('products');
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, '');
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     return Container(); // Replace with the desired search results widget
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return FutureBuilder<QuerySnapshot>(
//       future: _collectionReference
//           .where('Name', isGreaterThanOrEqualTo: query)
//           .where('Name', isLessThan: query + 'z')
//           .get(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasData) {
//           List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (BuildContext context, int index) {
//               Map<String, dynamic>? productData =
//               documents[index].data() as Map<String, dynamic>?;
//               if (productData == null) {
//                 return const SizedBox.shrink();
//               }
//               Product product = Product(
//                 id: documents[index].id,
//                 name: productData['Name'],
//                 category: productData['Category'],
//                 stockQnt: productData['Stock qnt'],
//                 price: productData['Price'],
//                 pdesc: productData['Pdesc'],
//                 pic: productData['Pic'],
//               );
//               return ListTile(
//                 title: Text(product.name),
//                 onTap: () {
//                   close(context, product.name);
//                 },
//               );
//             },
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
// }















// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'homepage.dart';
// import 'favorites.dart';
//
// class Product {
//   String id; // Add an ID field to uniquely identify each product
//   String name;
//   String category;
//   int stockQnt;
//   double price;
//   String pdesc;
//   String pic;
//   int quantity;
//   Product({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.stockQnt,
//     required this.price,
//     required this.pdesc,
//     required this.pic,
//   }): quantity = 0;
// }
//
// class ProductListPage extends StatelessWidget {
//   final CollectionReference _collectionReference =
//   FirebaseFirestore.instance.collection('products');
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _collectionReference.snapshots(),
//         builder:
//             (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return const Text('Something went wrong');
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (BuildContext context, int index) {
//               Map<String, dynamic>? productData =
//               documents[index].data() as Map<String, dynamic>?;
//               if (productData == null) {
//                 return const SizedBox.shrink();
//               }
//               Product product = Product(
//                 id: documents[index].id,
//                 name: productData['Name'],
//                 category: productData['Category'],
//                 stockQnt: productData['Stock qnt'],
//                 price: productData['Price'],
//                 pdesc: productData['Pdesc'],
//                 pic: productData['Pic'],
//               );
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text(product.name),
//                               content: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(
//                                     width: double.infinity,
//                                     height: 200,
//                                     child: Image.network(product.pic, fit: BoxFit.cover),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text('Category: ${product.category}'),
//                                   Text('Stock: ${product.stockQnt}'),
//                                   Text('Price: ${product.price}'),
//                                   Text('Description: ${product.pdesc}'),
//                                 ],
//                               ),
//                               actions: [
//                                 TextButton(
//                                   child: const Text('Add to Favorites'),
//                                   onPressed: () {
//                                     FavoritesPage.addToFavorites(product.id);
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: const Text('Close'),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       },
//                       child: SizedBox(
//                         width: 100,
//                         height: 100,
//                         child: Image.network(product.pic),
//                       ),
//                     ),
//                     // SizedBox(
//                     //   width: 100,
//                     //   height: 100,
//                     //   child: Image.network(product.pic),
//                     // ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(product.name,
//                                 style: const TextStyle(fontSize: 18)),
//                             //Text(product.category),
//                             Text('Quantity: ${product.stockQnt}'),
//                             Text('Price: ${product.price}'),
//                             //Text(product.pdesc),
//                           ],
//                         ),
//                       ),
//                     ),
//                     product.stockQnt > 0 // Check if the stock is available
//                         ? IconButton(
//                       icon: const Icon(Icons.add_shopping_cart),
//                       onPressed: () {
//                         // Reduce the stock by 1 and update the database
//                         _collectionReference.doc(product.id).update({
//                           'Stock qnt': product.stockQnt - 1,
//                         });
//                         mycart.addToCart(product);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Added to cart'),
//                             duration: Duration(seconds: 2),
//                           ),
//                         );
//                       },
//                     )
//                         : const Text(
//                       'Out of Stock',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
