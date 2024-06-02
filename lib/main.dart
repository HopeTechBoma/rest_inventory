import 'package:flutter/material.dart';
// import 'package:rest_inventory/widgets/registration_form.dart';
import 'package:rest_inventory/widgets/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rest_inventory/widgets/dashb.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCe62kLYJEs_IiEWjym4KPGuBeHIV3MQpE',
      authDomain: 'rest-inventory-40605.firebaseapp.com',
      projectId: 'rest-inventory-40605',
      storageBucket: 'rest-inventory-40605.appspot.com',
      messagingSenderId: 'your_messaging_sender_id',
      appId: '1:803729159690:android:18cef5ed8e8e8a993e11f3',
    ),
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Univers des Excellent '),
    );
    // routes: RegisterPage.ROUTE_NAME => (context) => RegisterPage(),  
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future navigateToSubPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      // appBar: AppBar(
        
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/24319.jpg', // Replace 'assets/background_image.jpg' with your actual image path
              fit: BoxFit.cover,
            ),
          ),

        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
              constraints: BoxConstraints.expand(height: 200.0, width: 200.0),
              child: CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('images/000_Par7482422-removebg-preview_modified.png'),
              ),
            ),
            SizedBox(height: 20), // Adjust the spacing between the image and text

            SizedBox(height: 20), // Adjust the spacing between the text and button
            Container(
              width: 200, // Set desired width
              height: 50, // Set desired height
              decoration: BoxDecoration(
                color: Colors.blue, // Set desired background color
                borderRadius: BorderRadius.circular(10), // Optional: Set border radius for rounded corners
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent, // Make the button transparent
                  elevation: 0, // Remove elevation
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                  );
                },
                child: Text(
                  'OUVRIR',
                  style: TextStyle(
                    fontSize: 20, // Set desired font size
                    color: Colors.white, // Set desired text color
                  ),
                ),
              ),
              ),

              ],
            ),
          ),
      //   Center(
        
      //   child: ElevatedButton(
      //     child: const Text('Open route'),
      //     onPressed: () {
      //       Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => Dashboard()),
      //      );
      //       // Navigate to second route when tapped.
      //     },
      //   ),
      // ),
        ]
      )
      
    );
  }
}

