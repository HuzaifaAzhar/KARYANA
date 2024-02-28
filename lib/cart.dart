import 'package:flutter/material.dart';
import 'categories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
//
// class Cart {
//   List<Product> _items = [];
//
//   void addToCart(Product product) {
//     int index = _items.indexWhere((p) => p.name == product.name);
//     if (index >= 0) {
//       // If the product is already in the cart, increment its quantity
//       if (product.stockQnt > 0) {
//         _items[index].quantity++;
//         product.stockQnt--;
//       } else {
//         return;
//       }
//     } else {
//       // If the product is not in the cart, add it to the cart with quantity 1
//       if (product.stockQnt > 0) {
//         product.stockQnt--;
//         product.quantity++;
//         _items.add(product);
//       } else {
//         return;
//       }
//     }
//   }
//
//   List<Product> get items {
//     return List.unmodifiable(_items);
//   }
//
//   void checkout(UserModel user, bool confirm) {
//     if (confirm) {
//       // create a new transaction and add it to the user's transactions list
//       String transactionId = DateTime.now().toString();
//       double totalAmount = _items.fold(0, (sum, item) => sum + item.price * item.quantity);
//       user.transactions.add(TransactionModel(
//         id: transactionId,
//         description: 'Purchase on ' + DateFormat.yMMMd().format(DateTime.now()),
//         amount: totalAmount,
//       ));
//
//       // add the items in the cart to the user's inventory
//       _items.forEach((item) {
//         Product userProduct = user.inventory.firstWhere((p) => p.name == item.name);
//         userProduct.stockQnt += item.quantity;
//       });
//
//       // clear the cart
//       _items.clear();
//     }
//
//     // update the last three transactions in the user's profile
//     List<TransactionModel> lastThreeTransactions = user.transactions.reversed.take(3).toList();
//     FirebaseFirestore.instance.collection('users').doc(user.uid).update({
//       'transactions': lastThreeTransactions.map((t) => {
//         'id': t.id,
//         'description': t.description,
//         'amount': t.amount,
//       }).toList(),
//     });
//   }
// }
class Cart {
  List<Product> _items = [];
  void addToCart(Product product) async {
    int index = _items.indexWhere((p) => p.name == product.name);
    if (index >= 0) {
      // If the product is already in the cart, increment its quantity
      if (product.stockQnt > 0) {
        _items[index].quantity++;
        product.stockQnt--;
      } else {
        return;
      }
    } else {
      // If the product is not in the cart, add it to the cart with quantity 1
      if (product.stockQnt > 0) {
        product.stockQnt--;
        product.quantity++;
        _items.add(product);
      } else {
        return;
      }
    }
    final CollectionReference _collectionReference =
    FirebaseFirestore.instance.collection('products');
    final DocumentSnapshot doc =
        await _collectionReference.doc(product.id).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final Sold = data['Sold'] ?? 0;
    _collectionReference.doc(product.id).update({
      'Sold': Sold + 1,
    });
  }

  double get totalPrice {
    return _items.fold(0, (total, product) => total + (product.price * product.quantity));
  }

  List<Product> get items {
    return List.unmodifiable(_items);
  }

  void clear() {
    _items.clear();
  }
}

class CartPage extends StatefulWidget {
  final Cart cart;

  const CartPage({super.key, required this.cart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackground(context),
      body: ListView.builder(
        itemCount: widget.cart.items.length,
        itemBuilder: (BuildContext context, int index) {
          Product product = widget.cart.items[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.network(product.pic),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontSize: 18)),
                        Text(product.category),
                        Text('Price: ${product.price}'),
                        Text('Quantity: ${product.quantity}'),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_shopping_cart),
                  onPressed: () async {
                    if (product.quantity > 1) {
                      product.quantity--;
                      final CollectionReference _collectionReference =
                      FirebaseFirestore.instance.collection('products');
                      final DocumentSnapshot doc =
                      await _collectionReference.doc(product.id).get();
                      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      final stockQnt = data['Stock qnt'];
                      final Sold=data['Sold']??0;
                      _collectionReference.doc(product.id).update({
                        'Stock qnt': stockQnt + 1,
                        'Sold':Sold-1,
                      });
                    } else {
                      product.quantity--;
                      List<Product> updatedItems = List.from(widget.cart.items);
                      updatedItems.removeAt(index);
                      widget.cart._items = updatedItems;
                      final CollectionReference _collectionReference =
                      FirebaseFirestore.instance.collection('products');
                      final DocumentSnapshot doc =
                      await _collectionReference.doc(product.id).get();
                      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      final stockQnt = data['Stock qnt'];
                      final Sold=data['Sold']??0;
                      _collectionReference.doc(product.id).update({
                        'Stock qnt': stockQnt + 1,
                        'Sold':Sold-1,
                      });
                    }
                    setState(() {});
                  },

                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price: ${widget.cart.totalPrice}'),
                ElevatedButton(
                  onPressed: () async {
                    // Create a new transaction document in the database
                    if(widget.cart.items.isNotEmpty){
                    final CollectionReference _transactionsCollectionReference =
                    FirebaseFirestore.instance.collection('transactions');
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final User? user = auth.currentUser;
                    final String? userId = user?.uid;
                    final transactionDocRef = await _transactionsCollectionReference
                        .add({
                      'user_id': userId,
                      'timestamp': FieldValue.serverTimestamp(),
                      'total_price': widget.cart.totalPrice,
                      'items': widget.cart.items.map((product) =>
                      {
                        'id': product.id,
                        'name':product.name,
                        'quantity': product.quantity,
                      }).toList(),
                    });
                    // Clear the cart and navigate to the home page
                    widget.cart.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Transaction completed successfully')),
                    );
                  }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cart is empty')),
                      );
                    }
                    },
                  child: const Text('Checkout'),
                ),
              // ElevatedButton(
              //   onPressed: () async {
              //     // Create a new transaction document in the database
              //     final CollectionReference _transactionsCollectionReference =
              //     FirebaseFirestore.instance.collection('transactions');
              //     final FirebaseAuth _auth = FirebaseAuth.instance;
              //     final User? user = _auth.currentUser;
              //     final String? userId = user?.uid;
              //     final transactionDocRef = await _transactionsCollectionReference.add({
              //       'user_id': userId,
              //       'timestamp': FieldValue.serverTimestamp(),
              //       'total_price': widget.cart.totalPrice,
              //       'items': widget.cart.items.map((product) => {
              //         'id': product.id,
              //         'quantity': product.quantity,
              //       }).toList(),
              //     });
              //
              //     // Clear the cart and navigate to the home page
              //     widget.cart.clear();
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => const HomePage()),
              //           (route) => false,
              //     );
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(content: Text('Purchase confirmed!')),
              //     );
              //   },
              //   child: const Text('Checkout'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
