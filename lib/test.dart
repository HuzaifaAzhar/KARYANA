// import 'package:flutter/material.dart';
//
// class HomePage extends StatefulWidget{
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   int myindex = 1;
//   List<Widget> tabs = const [TestFile(), MyListView()];
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Karyana'),
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
//       body: tabs[myindex],
//     );
//   }
// }
//
// class TestFile extends StatelessWidget {
//   const TestFile({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold();
//   }
// }
//
// class MyListView extends StatefulWidget {
//   const MyListView({Key? key}) : super(key: key);
//
//   @override
//   State<MyListView> createState() => _MyListViewState();
// }
//
// class _MyListViewState extends State<MyListView> {
//
//   List imagelist = [
//     'assets/Images/broom.jpg',
//     'assets/Images/cheap apple.jpg',
//     'assets/Images/dedoderant.png',
//     'assets/Images/hat.jpg',
//     'assets/Images/japan.png',
//     'assets/Images/milk.jpg',
//     'assets/Images/not cheap apple.png',
//     'assets/Images/nuke.jpg',
//     'assets/Images/pancakes.jpg',
//     'assets/Images/pet allgator.jpg',
//     'assets/Images/tank.jpg'
//   ];
//
//   List<String> namelist = [
//     'broom',
//     'cheap apple',
//     'dedoderant',
//     'hat',
//     'japan',
//     'milk',
//     'not cheap apple',
//     'nuke',
//     'pancakes',
//     'pet allgator',
//     'tank',
//   ];
//
//   List<double> price = [
//     30, 10, 40, 20, 900, 45, 12, 54, 76, 89, 23.75,
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: ListView.builder(
//         itemCount: imagelist.length,
//         itemBuilder: (BuildContext context, int index) {
//           return ListTile(
//             leading: SizedBox(
//               height: 60,
//               width: 60,
//               child: Image.asset(imagelist[index]),
//             ),
//             title: Text(namelist[index]),
//             subtitle: Text('Rs ${price[index]}'),
//             trailing: const IconButton(
//               icon: Icon(Icons.add),
//               onPressed: null,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
