import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'userentry.dart';
import 'main.dart';

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
            return  UserProfileScreen(email:email);
          } else if (snapshot.hasError) {
            // Handle error state
            return Scaffold(
              backgroundColor: getBackground(context),
              body: Center(
                child: TextButton(
                  child: const Text('Please set up your profile. Click here to enter data.'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EnterUserDataScreen()),
                    );
                  },
                ),
              ),
            );
          } else {
            // Handle loading state
            return Scaffold(
              backgroundColor: getBackground(context),
              body: const Center(
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

  UserProfileScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _userRepository.getUserByEmail(email),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: getBackground(context),
            body: const Center(
              child: CircularProgressIndicator(
               // valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF333652)),
              ),
            ),
          );
        }
        UserModel user = snapshot.data!;
        return Scaffold(
          backgroundColor: getBackground(context),
          body: Center(
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16.0),
                if(user.profilePictureUrl.isNotEmpty)
                CircleAvatar(
                  backgroundColor: Colors.grey,
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
                ],
              ),
            ),
          ),
        );
      },
    );
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
