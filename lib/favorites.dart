import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final CollectionReference _collectionReference =
  FirebaseFirestore.instance.collection('favorites');

  FavoritesPage();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('You must be logged in to view favorites.'));
    }

    final String userId = user.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _collectionReference
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return const Center(child: Text('No favorite products yet.'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              Map<String, dynamic>? favoriteData =
              documents[index].data() as Map<String, dynamic>?;
              if (favoriteData == null) {
                return const SizedBox.shrink();
              }
              String productId = favoriteData['productId'];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> productSnapshot) {
                  if (productSnapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  Map<String, dynamic>? productData =
                  productSnapshot.data!.data() as Map<String, dynamic>?;
                  if (productData == null) {
                    return const Center(child:Text('No Items in Favorites!'),);
                  }
                  return ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.network(productData['Pic']),
                    ),
                    title: Text(productData['Name']),
                    subtitle: Text('Price: ${productData['Price']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _collectionReference.doc(documents[index].id).delete();
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  static Future<void> addToFavorites(String productId) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Future.error('You must be logged in to add to favorites.');
    }

    final String userId = user.uid;

    CollectionReference favoritesReference =
    FirebaseFirestore.instance.collection('favorites');
    QuerySnapshot favoritesQuery = await favoritesReference
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: userId)
        .get();
    if (favoritesQuery.docs.isEmpty) {
      await favoritesReference.add({
        'productId': productId,
        'userId': userId,
      });
    }
  }
}
