import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'emailverification.dart';
import 'homepage.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

}

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ),
  );
}

void _login(String email, String password, BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      showSnackbar(context, 'Please verify your email to continue!');
      await FirebaseAuth.instance.signOut();
    } else {
      showSnackbar(context, 'User is signed in!');
      //Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FeedbackPage()));
      Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const HomePage()));

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

Map<int, Color> color =
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
MaterialColor colorCustom = MaterialColor(0xFF333652, color);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SFPRODISPLAY',
        primarySwatch: colorCustom,
      ),
      home: const MyHomePage(title: 'Karyana'),
    );
  }
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight:45,
        title: Text(widget.title),
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
              const Image(
                image: AssetImage('assets/Images/karyana.png'),
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
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter Your Email Address',
                ),
              ),
              ),
              const SizedBox(height: 20),
              SizedBox(width: 300,child: TextField
                (
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter Your Password',
                ),
              ),
              ),
              const SizedBox(height: 20),
          SizedBox(height: 35,width: 125,
            child:
              ElevatedButton(onPressed:(){_login(emailController.text.toString(),passwordController.text.toString(),context);},child: const Text('Login')),
          ),
              const SizedBox(height: 10),
              SizedBox(height: 35,width: 125,
               child: ElevatedButton(onPressed:() async {
                  await _signup(emailController.text.toString(),passwordController.text.toString(),context);
                  if(FirebaseAuth.instance.currentUser?.email != null && !FirebaseAuth.instance.currentUser!.emailVerified){
                    Navigator.push(context, MaterialPageRoute(builder: (ctx)=>const EmailVerificationScreen()));
                  }
                }, child: const Text('Sign Up')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
