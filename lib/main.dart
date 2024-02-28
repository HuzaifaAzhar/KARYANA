import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'emailverification.dart';
import 'firebase_options.dart';
import 'homepage.dart';
import 'settings.dart';

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
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.black,
    ),
    colorScheme: ColorScheme(
      primary: Colors.red,
      secondary: Colors.red,
      surface: Colors.black,
      background: Colors.black,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
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
      backgroundColor: Colors.red,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 16, color: Colors.white),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
      ),
    ),
  );

  ThemeData lightTheme = ThemeData(
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    colorScheme: const ColorScheme(
      primary: Colors.red,
      primaryContainer: Colors.blueGrey,
      secondary: Colors.white,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black87,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyText1: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle>(
          const TextStyle(fontSize: 16, color: Colors.white),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
    ),
    brightness: Brightness.light,
    primaryColor: Colors.black87,
    fontFamily: 'SFPRODISPLAY',
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
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()));
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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => const EmailVerificationScreen()));
      } else {
        showSnackbar(context, 'User is signed in!');

        Navigator.push(
            context, MaterialPageRoute(builder: (ctx) => const HomePage()));

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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> forgotPassword(BuildContext contxt, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      showSnackbar(contxt, e.toString());
      return;
    } catch (e) {
      showSnackbar(contxt, e.toString());
      return;
    }
    showSnackbar(contxt, 'Email sent Successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    AssetImage img;
    if (darkModeProvider.isDarkModeEnabled) {
      img = const AssetImage('assets/Images/karyana_rev.png');
    } else {
      img = const AssetImage('assets/Images/karyana.png');
    }
    return Scaffold(
      backgroundColor: getBackground(context),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 45,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              Container(
                height: 250,
                width: 250,
                child: Image(
                  image: img,
                ),
              ),
              const SizedBox(
                width: 300,
                child: Text(
                  'Shopping Simplified',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  cursorColor: Colors.black,
                  controller: emailController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.person_2_outlined),
                    labelText: 'Email',
                    hintText: 'Enter Your Email Address',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: TextField(
                  cursorColor: Colors.black,
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    labelText: 'Password',
                    hintText: 'Enter Your Password',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  height: 40,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              isLoading = true;
                            });
                            _login(emailController.text.toString(),
                                passwordController.text.toString(), context);
                          },
                    style:
                        ElevatedButton.styleFrom(shape: const StadiumBorder()),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  onPressed: () async {
                    await _signup(emailController.text.toString(),
                        passwordController.text.toString(), context);
                    if (FirebaseAuth.instance.currentUser?.email != null &&
                        !FirebaseAuth.instance.currentUser!.emailVerified) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const EmailVerificationScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  forgotPassword(context, emailController.text.toString());
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

Future<User?> _signup(String emai, String passwrd, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: emai, password: passwrd);
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

Map<int, Color> swatch = {
  50: const Color.fromRGBO(255, 0, 0, .1),
  100: const Color.fromRGBO(255, 0, 0, .2),
  200: const Color.fromRGBO(255, 0, 0, .3),
  300: const Color.fromRGBO(255, 0, 0, .4),
  400: const Color.fromRGBO(255, 0, 0, .5),
  500: const Color.fromRGBO(255, 0, 0, .6),
  600: const Color.fromRGBO(255, 0, 0, .7),
  700: const Color.fromRGBO(255, 0, 0, .8),
  800: const Color.fromRGBO(255, 0, 0, .9),
  900: const Color.fromRGBO(255, 0, 0, 1),
};

Color getBackground(BuildContext context) {
  final darkModeProvider = Provider.of<DarkModeProvider>(context);
  if (darkModeProvider.isDarkModeEnabled) {
    return Color(0xff000000);
  } else {
    return Color(0xFFFFFFFF);
  }
}

Color getBorder(BuildContext context) {
  final darkModeProvider = Provider.of<DarkModeProvider>(context);
  if (darkModeProvider.isDarkModeEnabled) {
    return const Color(0xFFE0E0E0);
  } else {
    return Colors.black;
  }
}

Color getBorderBG(context) {
  final darkModeProvider = Provider.of<DarkModeProvider>(context);
  if (darkModeProvider.isDarkModeEnabled) {
    return const Color(0xFF262626);
  } else {
    return const Color(0xFFEFEFEF);
  }
}
