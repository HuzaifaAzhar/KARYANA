import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'emailverification.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'emailverification.dart';
import 'homepage.dart';
import 'package:provider/provider.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final darkModeProvider = DarkModeProvider();
  bool isSystemDarkModeEnabled =
      WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  if (isSystemDarkModeEnabled) {
    darkModeProvider.toggleDarkMode(true);
  }

  runApp(
    ChangeNotifierProvider<DarkModeProvider>.value(
      value: darkModeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final color = darkModeProvider.isDarkModeEnabled ? darkTheme : lightTheme;
    return MaterialApp(
      title: 'K A R Y A N A',
      debugShowCheckedModeBanner: false,
      theme: color,
      home: const MyHomePage(title: 'K A R Y A N A'),
    );
  }

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    fontFamily: 'SFPRODISPLAY',
    primarySwatch: MaterialColor(0xFFFF0000, swatch),
    backgroundColor: Colors.black87,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black87,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      //toolbarTextStyle: TextStyle(color: Colors.white),  // Customize the app bar title text style
      backgroundColor: Colors.red,  // Customize the app bar background color
      iconTheme: IconThemeData(color: Colors.white),// Customize the color of icons in the app bar
      // Add more properties as needed
    ),
    //  elevatedButtonTheme: ElevatedButtonThemeData(
    //   style: ButtonStyle(
    //     textStyle: MaterialStateProperty.all<TextStyle>(
    //       TextStyle(fontSize: 16, color: Colors.black),  // Customize the button text style
    //     ),
    //     backgroundColor: MaterialStateProperty.all<Color>(Colors.black),  // Change the button color to light grey
    //   ),
    //
    // ),

  );

  ThemeData lightTheme = ThemeData(
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black87,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      //toolbarTextStyle: TextStyle(color: Colors.white),  // Customize the app bar title text style
      backgroundColor: Colors.black87,  // Customize the app bar background color
      iconTheme: IconThemeData(color: Colors.white),// Customize the color of icons in the app bar
      // Add more properties as needed
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  // Customize the headline text style
      bodyText1: TextStyle(fontSize: 16),  // Customize the body text style
      // Add more text styles as needed
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 16, color: Colors.white),  // Customize the button text style
        ),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black87), // Change the button color to light grey
      ),

    ),
    brightness: Brightness.light,
    primaryColor: Colors.black87,
    fontFamily: 'SFPRODISPLAY',
    backgroundColor: Colors.white,
    primarySwatch: MaterialColor(0xFF000000, swatch),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isLoggedIn = false;
  void checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // User is already logged in, navigate to the home page
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
    }
  }
  @override
  void initState() {
    super.initState();
    checkLoggedInStatus();
  }
  void _login(String email, String password, BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        //showSnackbar(context, 'Please verify your email to continue!');
        Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const EmailVerificationScreen()));
        //await FirebaseAuth.instance.signOut();
      } else {
        showSnackbar(context, 'User is signed in!');
        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FeedbackPage()));
        Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const HomePage()));
        //SharedPreferences.setMockInitialValues({});
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isLoggedIn', true);

      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackbar(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showSnackbar(context, 'Wrong password provided for that user.');
      } else {
        showSnackbar(context, 'Error: ${e.code}');
      }
    } catch (e) {
      showSnackbar(context, e.toString());
    }
    finally {
      setState(() {
        isLoading = false; // Reset isLoading back to false
      });
    }
  }

  Future<void> forgotPassword(BuildContext contxt,String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // An error occurred while sending the password reset email
      // You can display an error message or handle the error as needed
      showSnackbar(contxt, e.toString());
      return;
    }
    catch (e) {
      // An error occurred while sending the password reset email
      // You can display an error message or handle the error as needed
      showSnackbar(contxt, e.toString());
      return;
    }
    showSnackbar(contxt, 'Email sent Successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    AssetImage img;
    if(darkModeProvider.isDarkModeEnabled) {
      img = const AssetImage('assets/Images/karyana_rev.png');
    }
    else
    {
      img = const AssetImage('assets/Images/karyana.png');
    }
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight:45,
        title: Text(widget.title,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              Container(height: 250,width: 250,child:
              Image(
                image: img,
              ),
              ),
              const SizedBox(width: 300,child: Text(
                'Shopping Simplified',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),),
              const SizedBox(height: 16,),
              const SizedBox(height: 20),
              SizedBox(width: 300,child: TextField
                (

                cursorColor:Colors.black ,
                controller: emailController,
                decoration: InputDecoration(

                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:  BorderRadius.circular(30),
                  ),
                  prefixIcon: const Icon(Icons.person_2_outlined),
                  labelText: 'Email',
                  hintText: 'Enter Your Email Address',
                ),

              ),
              ),
              const SizedBox(height: 20),
              SizedBox(width: 300,child: TextField
                (

                cursorColor:Colors.black ,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(

                    borderRadius:  BorderRadius.circular(30),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  labelText: 'Password',
                  hintText: 'Enter Your Password',
                ),
              ),
              ),
              const SizedBox(height: 20),
              SizedBox(height: 40, width: 120, child: ElevatedButton(
                onPressed: isLoading ? null : () {
                  setState(() {
                    isLoading = true;
                  });
                  _login(emailController.text.toString(), passwordController.text.toString(), context);
                },
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                child: isLoading
                    ? const CircularProgressIndicator() // Show circular progress indicator when isLoading is true
                    : const Text('Login',style: TextStyle(fontSize: 16),),
              )
              ),
              const SizedBox(height: 10),
              SizedBox(height: 40,width: 120,
                child: ElevatedButton(onPressed:() async {
                  await _signup(emailController.text.toString(),passwordController.text.toString(),context);
                  if(FirebaseAuth.instance.currentUser?.email != null && !FirebaseAuth.instance.currentUser!.emailVerified){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const EmailVerificationScreen()));
                  }
                },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text('Sign Up',style: TextStyle(fontSize: 16),),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Call the forgotPassword function when the text is pressed
                  forgotPassword(context,emailController.text.toString());
                },
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}



Future<User?> _signup(String emai,String passwrd,BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emai,
        password: passwrd
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      showSnackbar(context, 'The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      showSnackbar(context, 'The account already exists for that email.');
    } else if (e.code == 'invalid-email') {
      showSnackbar(context, 'The email address is not valid.');
    } else {
      showSnackbar(context, 'Error: ${e.code}');
    }
    return null;
  } catch (e) {
    showSnackbar(context, e.toString());
    return null;
  }
}

Map<int, Color> swatch =
{
  50:const Color.fromRGBO(51,54,82, .1),
  100:const Color.fromRGBO(51,54,82, .2),
  200:const Color.fromRGBO(51,54,82, .3),
  300:const Color.fromRGBO(51,54,82, .4),
  400:const Color.fromRGBO(51,54,82, .5),
  500:const Color.fromRGBO(51,54,82, .6),
  600:const Color.fromRGBO(51,54,82, .7),
  700:const Color.fromRGBO(51,54,82, .8),
  800:const Color.fromRGBO(51,54,82, .9),
  900:const Color.fromRGBO(51,54,82, 1),
};

Color getBackground(BuildContext context)
{
  final darkModeProvider = Provider.of<DarkModeProvider>(context);
  if(darkModeProvider.isDarkModeEnabled)
  {
    return Color(0xff000000);
  }
  else
  {
    return Color(0xFFFFFFFF);
  }
}

Color getBorder(BuildContext context)
{
  final darkModeProvider = Provider.of<DarkModeProvider>(context);
  if(darkModeProvider.isDarkModeEnabled){
    return const Color(0xFFE0E0E0);
  }
  else{return Colors.black;}
}

Color getBorderBG(context)
{
  final darkModeProvider = Provider.of<DarkModeProvider>(context);
  if(darkModeProvider.isDarkModeEnabled){
    return const Color(0xFF262626);

  }
  else{return const Color(0xFFEFEFEF);}
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   final darkModeProvider = DarkModeProvider();
//   bool isSystemDarkModeEnabled =
//       WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
//   if (isSystemDarkModeEnabled) {
//     darkModeProvider.toggleDarkMode(true);
//   }
//
//   runApp(
//     ChangeNotifierProvider<DarkModeProvider>.value(
//       value: darkModeProvider,
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     final darkModeProvider = Provider.of<DarkModeProvider>(context);
//     final color = darkModeProvider.isDarkModeEnabled ? darkTheme : lightTheme;
//     return MaterialApp(
//       title: 'K A R Y A N A',
//       debugShowCheckedModeBanner: false,
//       theme: color,
//       home: const MyHomePage(title: 'K A R Y A N A'),
//     );
//   }
//
//   ThemeData darkTheme = ThemeData(
//     brightness: Brightness.dark,
//     primaryColor: Colors.black,
//     fontFamily: 'SFPRODISPLAY',
//     primarySwatch: MaterialColor(0xFFFF0000, swatch),
//     backgroundColor: Colors.black87,
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Colors.black87,
//       selectedItemColor: Colors.red,
//       unselectedItemColor: Colors.white,
//     ),
//     appBarTheme: const AppBarTheme(
//       foregroundColor: Colors.white,
//       // textTheme: TextTheme(
//       //   titleMedium: TextStyle(color: Colors.white),// Customize the body text style
//       //   // Add more text styles as needed
//       // ),
//       backgroundColor: Colors.red,  // Customize the app bar background color
//       iconTheme: IconThemeData(color: Colors.white),// Customize the color of icons in the app bar
//       // Add more properties as needed
//     ),
//     //  elevatedButtonTheme: ElevatedButtonThemeData(
//     //   style: ButtonStyle(
//     //     textStyle: MaterialStateProperty.all<TextStyle>(
//     //       TextStyle(fontSize: 16, color: Colors.black),  // Customize the button text style
//     //     ),
//     //     backgroundColor: MaterialStateProperty.all<Color>(Colors.black),  // Change the button color to light grey
//     //   ),
//     //
//     // ),
//
//   );
//
//   ThemeData lightTheme = ThemeData(
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: Colors.black87,
//       selectedItemColor: Colors.red,
//       unselectedItemColor: Colors.black87,
//     ),
//     appBarTheme: const AppBarTheme(
//       foregroundColor: Colors.white,
//       // textTheme: TextTheme(
//       //   titleMedium: TextStyle(color: Colors.white),// Customize the body text style
//       //   // Add more text styles as needed
//       // ),
//       backgroundColor: Colors.black87,  // Customize the app bar background color
//       iconTheme: IconThemeData(color: Colors.white),// Customize the color of icons in the app bar
//       // Add more properties as needed
//     ),
//     textTheme: const TextTheme(
//       headline1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  // Customize the headline text style
//       bodyText1: TextStyle(fontSize: 16),  // Customize the body text style
//       // Add more text styles as needed
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ButtonStyle(
//         textStyle: MaterialStateProperty.all<TextStyle>(
//           const TextStyle(fontSize: 16, color: Colors.white),  // Customize the button text style
//         ),
//         backgroundColor: MaterialStateProperty.all<Color>(Colors.black87), // Change the button color to light grey
//       ),
//
//     ),
//     brightness: Brightness.light,
//     primaryColor: Colors.black87,
//     fontFamily: 'SFPRODISPLAY',
//     backgroundColor: Colors.white,
//     primarySwatch: MaterialColor(0xFF000000, swatch),
//   );
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//   bool isLoggedIn = false;
//   void checkLoggedInStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//     if (isLoggedIn) {
//       // User is already logged in, navigate to the home page
//       Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));
//     }
//   }
//   @override
//   void initState() {
//     super.initState();
//     checkLoggedInStatus();
//   }
//   void _login(String email, String password, BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       if (userCredential.user != null && !userCredential.user!.emailVerified) {
//         showSnackbar(context, 'Please verify your email to continue!');
//         await FirebaseAuth.instance.signOut();
//       } else {
//         showSnackbar(context, 'User is signed in!');
//         //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FeedbackPage()));
//         Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const HomePage()));
//         //SharedPreferences.setMockInitialValues({});
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setBool('isLoggedIn', true);
//
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         showSnackbar(context, 'No user found for that email.');
//       } else if (e.code == 'wrong-password') {
//         showSnackbar(context, 'Wrong password provided for that user.');
//       } else {
//         showSnackbar(context, 'Error: ${e.code}');
//       }
//     } catch (e) {
//       showSnackbar(context, e.toString());
//     }
//     finally {
//       setState(() {
//         isLoading = false; // Reset isLoading back to false
//       });
//     }
//   }
//
//   Future<void> forgotPassword(BuildContext contxt,String email) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       // An error occurred while sending the password reset email
//       // You can display an error message or handle the error as needed
//       showSnackbar(contxt, e.toString());
//       return;
//     }
//     catch (e) {
//       // An error occurred while sending the password reset email
//       // You can display an error message or handle the error as needed
//       showSnackbar(contxt, e.toString());
//       return;
//     }
//     showSnackbar(contxt, 'Email sent Successfully!');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final darkModeProvider = Provider.of<DarkModeProvider>(context);
//     AssetImage img;
//     if(darkModeProvider.isDarkModeEnabled) {
//       img = const AssetImage('assets/Images/karyana_rev.png');
//     }
//     else
//     {
//       img = const AssetImage('assets/Images/karyana.png');
//     }
//     return Scaffold(
//       backgroundColor: Theme.of(context).backgroundColor,
//       appBar: AppBar(
//         centerTitle: true,
//         toolbarHeight:45,
//         title: Text(widget.title,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(30),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const SizedBox(height: 20),
//               Container(height: 250,width: 250,child:
//               Image(
//                 image: img,
//               ),
//               ),
//               const SizedBox(width: 300,child: Text(
//                 'Shopping Simplified',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),),
//               const SizedBox(height: 16,),
//               const SizedBox(height: 20),
//               SizedBox(width: 300,child: TextField
//                 (
//
//                 cursorColor:Colors.black ,
//                 controller: emailController,
//                 decoration: InputDecoration(
//
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius:  BorderRadius.circular(30),
//                   ),
//                   prefixIcon: const Icon(Icons.person_2_outlined),
//                   labelText: 'Email',
//                   hintText: 'Enter Your Email Address',
//                 ),
//
//               ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(width: 300,child: TextField
//                 (
//
//                 cursorColor:Colors.black ,
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//
//                     borderRadius:  BorderRadius.circular(30),
//                   ),
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   labelText: 'Password',
//                   hintText: 'Enter Your Password',
//                 ),
//               ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(height: 40, width: 120, child: ElevatedButton(
//                 onPressed: isLoading ? null : () {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   _login(emailController.text.toString(), passwordController.text.toString(), context);
//                 },
//                 style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
//                 child: isLoading
//                     ? const CircularProgressIndicator() // Show circular progress indicator when isLoading is true
//                     : const Text('Login',style: TextStyle(fontSize: 16),),
//               )
//               ),
//               const SizedBox(height: 10),
//               SizedBox(height: 40,width: 120,
//                 child: ElevatedButton(onPressed:() async {
//                   await _signup(emailController.text.toString(),passwordController.text.toString(),context);
//                   if(FirebaseAuth.instance.currentUser?.email != null && !FirebaseAuth.instance.currentUser!.emailVerified){
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>const EmailVerificationScreen()));
//                   }
//                 },
//                   style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
//                   child: const Text('Sign Up',style: TextStyle(fontSize: 16),),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   // Call the forgotPassword function when the text is pressed
//                   forgotPassword(context,emailController.text.toString());
//                 },
//                 child: const Text('Forgot Password?'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// void showSnackbar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(message),
//       duration: const Duration(seconds: 3),
//     ),
//   );
// }
//
//
//
// Future<User?> _signup(String emai,String passwrd,BuildContext context) async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emai,
//         password: passwrd
//     );
//     return userCredential.user;
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'weak-password') {
//       showSnackbar(context, 'The password provided is too weak.');
//     } else if (e.code == 'email-already-in-use') {
//       showSnackbar(context, 'The account already exists for that email.');
//     } else if (e.code == 'invalid-email') {
//       showSnackbar(context, 'The email address is not valid.');
//     } else {
//       showSnackbar(context, 'Error: ${e.code}');
//     }
//     return null;
//   } catch (e) {
//     showSnackbar(context, e.toString());
//     return null;
//   }
// }
//
// Map<int, Color> swatch =
// {
//   50:const Color.fromRGBO(51,54,82, .1),
//   100:const Color.fromRGBO(51,54,82, .2),
//   200:const Color.fromRGBO(51,54,82, .3),
//   300:const Color.fromRGBO(51,54,82, .4),
//   400:const Color.fromRGBO(51,54,82, .5),
//   500:const Color.fromRGBO(51,54,82, .6),
//   600:const Color.fromRGBO(51,54,82, .7),
//   700:const Color.fromRGBO(51,54,82, .8),
//   800:const Color.fromRGBO(51,54,82, .9),
//   900:const Color.fromRGBO(51,54,82, 1),
// };
// MaterialColor colorCustom = MaterialColor(0xFF333652, color);


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'firebase_options.dart';
// import 'emailverification.dart';
// import 'homepage.dart';
// import 'package:provider/provider.dart';
// import 'settings.dart';
//
// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(
//     ChangeNotifierProvider(
//     create: (context) => DarkModeProvider(),
//     child: MyApp(),
//   ),);
// }
//
//
// class MyApp extends StatelessWidget {
//   MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final darkModeProvider = Provider.of<DarkModeProvider>(context);
//     final color = darkModeProvider.isDarkModeEnabled ? darkTheme : lightTheme;
//     return MaterialApp(
//       title: 'K A R Y A N A',
//       debugShowCheckedModeBanner: false,
//       theme: color,
//       home: const MyHomePage(title: 'K A R Y A N A'),
//     );
//   }
//   ThemeData darkTheme = ThemeData(
//     brightness: Brightness.values[0],
//     primaryColor: Colors.black,
//     fontFamily: 'SFPRODISPLAY',
//     backgroundColor: Colors.black,
//     primarySwatch: MaterialColor(0xFF000000, swatch),
//   );
//   ThemeData lightTheme = ThemeData(
//     brightness: Brightness.light,
//     primaryColor: Colors.white,
//     fontFamily: 'SFPRODISPLAY',
//     backgroundColor: Colors.white,
//     primarySwatch: MaterialColor(0xFFFFFFFF, swatch),
//   );
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;
//
//
//   void _login(String email, String password, BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       if (userCredential.user != null && !userCredential.user!.emailVerified) {
//         showSnackbar(context, 'Please verify your email to continue!');
//         await FirebaseAuth.instance.signOut();
//       } else {
//         showSnackbar(context, 'User is signed in!');
//         //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FeedbackPage()));
//         Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const HomePage()));
//
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         showSnackbar(context, 'No user found for that email.');
//       } else if (e.code == 'wrong-password') {
//         showSnackbar(context, 'Wrong password provided for that user.');
//       } else {
//         showSnackbar(context, 'Error: ${e.code}');
//       }
//     } catch (e) {
//       showSnackbar(context, e.toString());
//     }
//     finally {
//       setState(() {
//         isLoading = false; // Reset isLoading back to false
//       });
//     }
//   }
//
//   Future<void> forgotPassword(BuildContext contxt,String email) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       // An error occurred while sending the password reset email
//       // You can display an error message or handle the error as needed
//       showSnackbar(contxt, e.toString());
//       return;
//     }
//     catch (e) {
//       // An error occurred while sending the password reset email
//       // You can display an error message or handle the error as needed
//       showSnackbar(contxt, e.toString());
//       return;
//     }
//     showSnackbar(contxt, 'Email sent Successfully!');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         toolbarHeight:45,
//         title: Text(widget.title,style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(30),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               const SizedBox(height: 20),
//               Container(height: 250,width: 250,child:
//               const Image(
//                 image: AssetImage('assets/Images/karyana.png'),
//               ),
//               ),
//               const SizedBox(width: 300,child: Text(
//                 'Shopping Simplified',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),),
//               const SizedBox(height: 16,),
//               const SizedBox(height: 20),
//               SizedBox(width: 300,child: TextField
//                 (
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius:  BorderRadius.circular(30),
//                   ),
//                   prefixIcon: const Icon(Icons.person_2_outlined),
//                   labelText: 'Email',
//                   hintText: 'Enter Your Email Address',
//                 ),
//               ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(width: 300,child: TextField
//                 (
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius:  BorderRadius.circular(30),
//                   ),
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   labelText: 'Password',
//                   hintText: 'Enter Your Password',
//                 ),
//               ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(height: 40, width: 120, child: ElevatedButton(
//                 onPressed: isLoading ? null : () {
//                   setState(() {
//                     isLoading = true;
//                   });
//                   _login(emailController.text.toString(), passwordController.text.toString(), context);
//                 },
//                   style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
//                 child: isLoading
//                     ? const CircularProgressIndicator() // Show circular progress indicator when isLoading is true
//                     : const Text('Login',style: TextStyle(fontSize: 16),),
//               )
//               ),
//               const SizedBox(height: 10),
//               SizedBox(height: 40,width: 120,
//                 child: ElevatedButton(onPressed:() async {
//                   await _signup(emailController.text.toString(),passwordController.text.toString(),context);
//                   if(FirebaseAuth.instance.currentUser?.email != null && !FirebaseAuth.instance.currentUser!.emailVerified){
//                     Navigator.push(context, MaterialPageRoute(builder: (context)=>const EmailVerificationScreen()));
//                   }
//                 },
//                   style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
//                   child: const Text('Sign Up',style: TextStyle(fontSize: 16),),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   // Call the forgotPassword function when the text is pressed
//                   forgotPassword(context,emailController.text.toString());
//                 },
//                 child: const Text('Forgot Password?'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// void showSnackbar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Text(message),
//       duration: const Duration(seconds: 3),
//     ),
//   );
// }
//
//
//
// Future<User?> _signup(String emai,String passwrd,BuildContext context) async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emai,
//         password: passwrd
//     );
//     return userCredential.user;
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'weak-password') {
//       showSnackbar(context, 'The password provided is too weak.');
//     } else if (e.code == 'email-already-in-use') {
//       showSnackbar(context, 'The account already exists for that email.');
//     } else if (e.code == 'invalid-email') {
//       showSnackbar(context, 'The email address is not valid.');
//     } else {
//       showSnackbar(context, 'Error: ${e.code}');
//     }
//     return null;
//   } catch (e) {
//     showSnackbar(context, e.toString());
//     return null;
//   }
// }
//
// Map<int, Color> swatch =
// {
//   50:const Color.fromRGBO(51,54,82, .1),
//   100:const Color.fromRGBO(51,54,82, .2),
//   200:const Color.fromRGBO(51,54,82, .3),
//   300:const Color.fromRGBO(51,54,82, .4),
//   400:const Color.fromRGBO(51,54,82, .5),
//   500:const Color.fromRGBO(51,54,82, .6),
//   600:const Color.fromRGBO(51,54,82, .7),
//   700:const Color.fromRGBO(51,54,82, .8),
//   800:const Color.fromRGBO(51,54,82, .9),
//   900:const Color.fromRGBO(51,54,82, 1),
// };
// // MaterialColor colorCustom = MaterialColor(0xFF333652, color);