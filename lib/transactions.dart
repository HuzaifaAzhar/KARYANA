import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'categories.dart';
import 'main.dart';

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({Key? key}) : super(key: key);
  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        title: const Text('Transactions History'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
        const SizedBox(height: 10),
        FutureBuilder<List<Transaction>>(
          future: _getRecentTransactions(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Error occurred while retrieving transactions.');
            }
            if (snapshot.hasData) {
              List<Transaction> transactions = snapshot.data!;
              return Column(
                children: transactions.map((transaction) {
                  return Column(
                    children: [
                      Text(
                        'Transaction ID: ${transaction.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                         Column(
                          children: transaction.products.map((product) {
                            return ListTile(
                              title: Text(product.name,
                                textAlign: TextAlign.center,
                              ),
                              subtitle: Text('Quantity: ${product.stockQnt}',
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        ),
                      Text('Total Price: ${transaction.totalPrice}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              );
            }
            return const Text('No transactions found.');
            },
            ),
          ],
        ),
    ),
      ),
    );
  }
}

class Transaction {
  final String id;
  final double totalPrice;
  final List<Product> products;

  Transaction({
    required this.id,
    required this.totalPrice,
    required this.products,
  });
}
final FirebaseAuth auth = FirebaseAuth.instance;
User? user = auth.currentUser;
Future<List<Transaction>> _getRecentTransactions(String userId) async {

  final CollectionReference _transactionsCollectionReference =
  FirebaseFirestore.instance.collection('transactions');

  try {
    QuerySnapshot transactionsSnapshot = await _transactionsCollectionReference
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    List<Transaction> transactions = [];

    for (DocumentSnapshot doc in transactionsSnapshot.docs) {
      Map<String, dynamic>? transactionData = doc.data() as Map<String, dynamic>?;
      if (transactionData != null) {
        List<Map<String, dynamic>> productDataList = List<Map<String, dynamic>>.from(transactionData['items']);
        List<Product> products = productDataList.map((productData) {
          return Product(
            name: productData['name'] ?? 'Name',
            category: productData['category'] ?? 'Category',
            price: productData['price'] ?? 0.0,
            pdesc: productData['pdesc'] ?? 'Description',
            pic: productData['pic'] ?? 'Picture',
            id: productData['id'] ?? 'ID',
            stockQnt: productData['quantity'],
            sold: productData['Sold']??0,
          );
        }).toList();

        Transaction transaction = Transaction(
          id: doc.id,
          totalPrice: transactionData['total_price'],
          products: products,
        );

        transactions.add(transaction);
      }
    }

    return transactions;
  } catch (error) {
    ScaffoldMessenger.of(FirebaseAuth.instance.currentUser!.metadata.creationTime as BuildContext).showSnackBar(
      SnackBar(
        content: Text('Error retrieving transactions: $error'),
      ),
    );
    return []; // Return an empty list in case of error or no transactions
  }
}