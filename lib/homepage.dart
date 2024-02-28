import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karyana/changepassword.dart';
import 'package:karyana/feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'categories.dart';
import 'profile.dart';
import 'cart.dart';
import 'favorites.dart';
import 'transactions.dart';
import 'userentry.dart';
import 'main.dart';
import 'settings.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int myindex = 2;

  DarkModeProvider darkModeProvider = DarkModeProvider();
  Future<String?> getProfilePictureUrl() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUser.email)
          .get();
      if (snapshot.size > 0) {
        final userData = snapshot.docs[0].data();
        return userData['profilePictureUrl'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'K A R Y A N A',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 45,
        //automaticallyImplyLeading: false,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(30),
        //   ),
        // ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myindex,
        //unselectedItemColor: darkModeProvider.isDarkModeEnabled ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF),
        //selectedItemColor: const Color(0xFFA500),

        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            myindex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            label: 'Explore',
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
        ],
      ),
      //body: Container(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF000000),
              ),
              child: Column(
                children: [
                  FutureBuilder<String?>(
                    future: getProfilePictureUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        final profilePictureUrl = snapshot.data!;
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final name = snapshot.data!;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundImage: NetworkImage(profilePictureUrl),
                          // child: Image.network(
                              //   profilePictureUrl,
                              //   fit: BoxFit.cover,
                             //  ),
                            ),
                            SizedBox(height: 7,),
                            Text(currentUser!.email.toString(),style: TextStyle(color: Colors.white),),
                          ],
                        );
                      }
                      return const SizedBox(); // Use a default image or placeholder here
                    },
                  ),

                ],
              ),

            ),

            ListTile(
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EnterUserDataScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Transaction History'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const TransactionsHistory()));
              },
            ),
            ListTile(
              title: const Text('Change Password'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const ChangePasswordScreen()));
              },
            ),
            ListTile(
              title: const Text('Give Feedback'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const FeedbackPage()));
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  MyApp()),
                );
              },
            ),
            //
          ],
        ),
      ),
      body: myindex == 0
          ? const Profile()
          : myindex == 1
          ? FavoritesPage()
          : myindex == 2
          ? ProductListPage()
          : myindex == 3
          ? CartPage(cart:mycart)
          : null,
    );
  }
}
final Cart mycart = Cart();





///////////////////////Without BurgerMenu AppDrawer/////////////////////////
// import 'package:flutter/material.dart';
// import 'categories.dart';
// import 'profile.dart';
// import 'cart.dart';
// import 'favorites.dart';
//
// class HomePage extends StatefulWidget{
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int myindex = 2;
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('K A R Y A N A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
//         centerTitle: true,
//         toolbarHeight:45,
//         automaticallyImplyLeading: false,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(30),
//           ),
//         ),
//       ),
//
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: myindex,
//         selectedItemColor: const Color(0xFF333652),
//         unselectedItemColor: const Color(0xff000000),
//         type: BottomNavigationBarType.shifting,
//         onTap: (index){
//           setState(() {
//             myindex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline_rounded),
//             activeIcon: Icon(Icons.person_rounded),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite_border_outlined),
//             activeIcon: Icon(Icons.favorite),
//             label: 'Favorites',
//           ),
//           BottomNavigationBarItem(
//             label:'Explore',
//             icon: Icon(Icons.search_outlined),
//             activeIcon: Icon(Icons.search),
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_bag_outlined),
//             activeIcon: Icon(Icons.shopping_bag),
//             label: 'Cart',
//           ),
//         ],
//       ),
//       body: myindex == 0
//           ? const Profile()
//           : myindex == 1
//           ? FavoritesPage()
//           : myindex == 2
//           ? ProductListPage()
//           : myindex == 3
//           ? CartPage(cart:mycart)
//           : null,
//     );
//   }
// }
// final Cart mycart = Cart();




