import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'userentry.dart';
import 'listview.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      String email = user.email!;
      final UserRepository _userRepository = UserRepository();
      return FutureBuilder<UserModel>(
        future: _userRepository.getUserByEmail(email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(
              title: 'My App',
              home: UserProfileScreen(email:email),
            );
          } else if (snapshot.hasError) {
            // Handle error state
            return Scaffold(
              body: Center(
                child: TextButton(
                  child: const Text('Please set up your profile. Click here to enter data.'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => EnterUserDataScreen()),
                    );
                  },
                ),
              ),
            );
          } else {
            // Handle loading state
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      );
    }
    else {
      // Handle case when user is null
      return Container();
    }
  }
}


class UserModel {
  final String uid;
  final String name;
  final String email;
  final String contact;
  final String address;
  final String profilePictureUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.contact,
    required this.address,
    required this.profilePictureUrl,
  });
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


class UserRepository {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<UserModel> getUserByEmail(String email) async{
    QuerySnapshot userSnapshot = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
    DocumentSnapshot userDoc = userSnapshot.docs.first;
    return getUser(userDoc.id);
  }

  Future<UserModel> getUser(String uid) async {
    DocumentSnapshot userSnapshot = await _usersCollection.doc(uid).get();

    return UserModel(
      uid: uid,
      name: userSnapshot['name'],
      email: userSnapshot['email'],
      contact: userSnapshot['contact'],
      address: userSnapshot['address'],
      profilePictureUrl: userSnapshot['profilePictureUrl'],
    );
  }
}
class UserProfileScreen extends StatelessWidget {
  final UserRepository _userRepository = UserRepository();
  final String email;

  UserProfileScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _userRepository.getUserByEmail(email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333652)),
            ),
          );
        }
        UserModel user = snapshot.data!;
        return Scaffold(
          body: Center(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16.0),
                if(user.profilePictureUrl.isNotEmpty)
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 50.0,
                  backgroundImage: NetworkImage(user.profilePictureUrl),
                ),
                const SizedBox(height: 16.0),
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  user.contact,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Text(
                  user.address,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                const Text(
                    'Last 3 transactions:',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  FutureBuilder<List<Transaction>>(
                    future: _getRecentTransactions(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
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
                                Text('Total Price: ${transaction.totalPrice}'),
                                const SizedBox(height: 8.0),
                                Text('Products:'),
                                Column(
                                  children: transaction.products.map((product) {
                                    return ListTile(
                                      title: Text(product.name),
                                      subtitle: Text('Quantity: ${product.quantity}'),
                                    );
                                  }).toList(),
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
      },
    );
  }

  Future<List<Transaction>> _getRecentTransactions(String userId) async {
    debugPrint('Fetching recent transactions...');

    final CollectionReference _transactionsCollectionReference =
    FirebaseFirestore.instance.collection('transactions');

    try {
      QuerySnapshot transactionsSnapshot = await _transactionsCollectionReference
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      debugPrint('Transactions retrieved successfully.');

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
              stockQnt: productData['stockQnt'] ?? 0,
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
      debugPrint('Error retrieving transactions: $error');
      return []; // Return an empty list in case of error or no transactions
    }
  }

}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'userentry.dart';
//
// class Profile extends StatelessWidget {
//   const Profile({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     User? user = auth.currentUser;
//     if (user != null) {
//       String email = user.email!;
//       final UserRepository _userRepository = UserRepository();
//       return FutureBuilder<UserModel>(
//         future: _userRepository.getUserByEmail(email),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return MaterialApp(
//               title: 'My App',
//               home: UserProfileScreen(email:email),
//             );
//           } else if (snapshot.hasError) {
//             // Handle error state
//             return Scaffold(
//               body: Center(
//                 child: TextButton(
//                   child: const Text('Please set up your profile. Click here to enter data.'),
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => EnterUserDataScreen()),
//                     );
//                   },
//                 ),
//               ),
//             );
//           } else {
//             // Handle loading state
//             return const Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//         },
//       );
//     }
//     else {
//       // Handle case when user is null
//       return Container();
//     }
//   }
// }
//
//
// class UserModel {
//   final String uid;
//   final String name;
//   final String email;
//   final String contact;
//   final String address;
//   final String profilePictureUrl;
//
//   UserModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.contact,
//     required this.address,
//     required this.profilePictureUrl,
//   });
// }
//
// class UserRepository {
//   final CollectionReference _usersCollection =
//   FirebaseFirestore.instance.collection('users');
//
// Future<UserModel> getUserByEmail(String email) async{
//   QuerySnapshot userSnapshot = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
//   DocumentSnapshot userDoc = userSnapshot.docs.first;
//   return getUser(userDoc.id);
// }
//
//   Future<UserModel> getUser(String uid) async {
//     DocumentSnapshot userSnapshot = await _usersCollection.doc(uid).get();
//
//     return UserModel(
//       uid: uid,
//       name: userSnapshot['name'],
//       email: userSnapshot['email'],
//       contact: userSnapshot['contact'],
//       address: userSnapshot['address'],
//       profilePictureUrl: userSnapshot['profilePictureUrl'],
//     );
//   }
// }
// class UserProfileScreen extends StatelessWidget {
//   final UserRepository _userRepository = UserRepository();
//   final String email;
//
//   UserProfileScreen({required this.email});
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<UserModel>(
//       future: _userRepository.getUserByEmail(email),
//       builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//              return  const Center(
//                child: CircularProgressIndicator(
//                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333652)),
//                ),
//              );
//          }
//         UserModel user = snapshot.data!;
//         return Scaffold(
//           body: Center(
//             child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const SizedBox(height: 16.0),
//                 if(user.profilePictureUrl.isNotEmpty)
//                 CircleAvatar(
//                   radius: 50.0,
//                   backgroundImage: NetworkImage(user.profilePictureUrl),
//                 ),
//                 const SizedBox(height: 16.0),
//                 Text(
//                   user.name,
//                   style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8.0),
//                 Text(
//                   user.email,
//                   style: const TextStyle(fontSize: 16.0),
//                 ),
//                 const SizedBox(height: 8.0),
//                 Text(
//                   user.contact,
//                   style: const TextStyle(fontSize: 16.0),
//                 ),
//                 const SizedBox(height: 8.0),
//                 Text(
//                   user.address,
//                   style: const TextStyle(fontSize: 16.0),
//                 ),
//                 const SizedBox(height: 16.0),
//                 const Text(
//                   'Last 3 transactions:',
//                   style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//           ),
//         );
//       },
//     );
//   }
// }
