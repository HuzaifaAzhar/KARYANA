import 'package:flutter/material.dart';
import 'listview.dart';
import 'profile.dart';
import 'cart.dart';
import 'favorites.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int myindex = 2;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karyana'),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myindex,
        selectedItemColor: const Color(0xFF333652),
        unselectedItemColor: const Color(0xff000000),
        type: BottomNavigationBarType.shifting,
        onTap: (index){
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
            label:'Explore',
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