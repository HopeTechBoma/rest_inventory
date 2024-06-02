import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rest_inventory/widgets/add_article.dart';
import 'package:rest_inventory/widgets/show_items.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboarPageState();
}

class _DashboarPageState extends State<DashboardPage> {
  //create the controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  CollectionReference addUser =
  FirebaseFirestore.instance.collection('users');
  
  Future<void> _registerUser() {
    return addUser
        .add({'Name': nameController.text, 'Email': emailController.text, 'Tel': mobileController.text})
        .then((value) => print('User Added'))
        .catchError((_) => print('Something Error In registering User'));
  }

   Future navigateToAddArticlePage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddArticles()));
  }

  Future navigateToItemPage(context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ItemListView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Page'),
      ),
      //for the form to be in center
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            shrinkWrap: true,
            children: [

            ElevatedButton(
                child: const Text('Ajouter des articles'),
                onPressed: () {
                    navigateToAddArticlePage(context);
                    // Navigate to second route when tapped.
                },
            ),

            SizedBox(
                height: 10,
            ),

            //create button for register
            ElevatedButton(
            onPressed: () {
              
            navigateToItemPage(context);

            },

            child: Text(
                'Register',
                style: TextStyle(
                fontSize: 30,
                ),
            ),
            
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createCommande() {
    print('start creating commande ...');
  }
}