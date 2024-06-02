import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rest_inventory/widgets/BoissonModel.dart';
import 'package:rest_inventory/widgets/dashb.dart';
import 'package:flutter/services.dart';

class ItemListView extends StatefulWidget {
  const ItemListView({Key? key}) : super(key: key);

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int totalResult = 0;
  String productCustomId = "";
  late String appBarTitle;
  String? _selectedDropdownTable;

  List<Map<String, dynamic>> selectedItems = [];

  List<BoissonModel> boissons = [];
  List<BoissonModel> selectedBoissons = [];

  void handleBoissonSelection(BoissonModel boisson) {
  setState(() {
    // Toggle the isSelected property of the boisson
    boisson.isSelected = !boisson.isSelected;

    // Update the selectedBoissons list based on the isSelected property
    if (boisson.isSelected) {
      selectedBoissons.add(boisson);
    } else {
      selectedBoissons.remove(boisson);
    }
  });
}

final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('rest_tables').snapshots();

  @override
  void initState() {
    super.initState();
    appBarTitle = 'Total: $totalResult FCFA';
    fetchData();
  }

  Future<void> fetchData() async {
    List<Map<String, dynamic>> data = await getData();
    setState(() {
      boissons = data
          .map((item) =>
              BoissonModel(item['name'], item['phoneNumber'], item['productId'], item['nbre_boissons'], item['product_image'], item['isSelected']))
          .toList();
    });
  }

  Future<List<Map<String, dynamic>>> getData() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('stocks').get();

    List<Map<String, dynamic>> data = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> docData =
      doc.data() as Map<String, dynamic>? ?? {}; // Handle null values gracefully
      String? categorieId = docData['id_boisson'];

      if (categorieId != null) {
        DocumentSnapshot categorieSnapshot =
            await _firestore.collection('categorie_boissons').doc(categorieId).get();

        if (categorieSnapshot.exists) {
          Map<String, dynamic>? productCategorieData =
              categorieSnapshot.data() as Map<String, dynamic>?; // Handle null values gracefully

          if (productCategorieData != null) {
            String? idCategorieProduit = doc.id;
            String? productCategoriesUrl =
                productCategorieData['prod_image_url'];
            String? categorie_libelle = productCategorieData['appellation'];
            String? nbre_boissons =
                docData['prix_unitaire'].toString();
                String? nbre_boissons2 = productCategorieData['nbre_boissons'].toString();

            if (productCategoriesUrl != null && categorie_libelle != null) {
              data.add({
                'name': categorie_libelle,
                'phoneNumber': nbre_boissons,
                'productId': idCategorieProduit,
                'nbre_boissons': nbre_boissons2,
                'product_image': productCategoriesUrl,
                'isSelected': false,
              });
            }
          }
        }
      }
    }
    return data;
  }

  void addItemsToArray(String productId, int quantity, String nbre_boissons) {
    setState(() {
      selectedItems.add({
        'product_id': productId,
        'quantityController': quantity,
        'nbre_boissons': nbre_boissons
      });
    });
  }

  Future<void> showCustomDialog(BuildContext context, String title, String productId, String nbre_boissons, String phoneNumber, Function(int, String) onDialogSubmitted) async {
    TextEditingController quantityController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text(title),
          title: Center(
            child: Text(title),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
               SizedBox(height: 16.0),
               TextField(
                controller: quantityController,
                keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
                ],
                decoration: InputDecoration(
                  labelText: 'Nombre des bouteilles',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                )
               )
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {

                    String quantityText = quantityController.text;
                    int quantity = int.tryParse(quantityText) ?? 0;
                    int totalPrice = quantity * int.parse(phoneNumber);

                    updateTotalResult(totalResult + totalPrice);

                    updateAppBarTitle();
                    addItemsToArray(productId, quantity, nbre_boissons);
                    // onDialogSubmitted(quantity, productId);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Valider',
                    style: TextStyle(color: Colors.white),
                  )
                )
              ],
            )
          ]
        );
      },
    );
  }

  void updateTotalResult(int newTotal) {
    setState(() {
      totalResult = newTotal;
    });
  }

  void updateAppBarTitle() {
    setState(() {
      appBarTitle = 'Total: $totalResult FCFA';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text(appBarTitle, style: TextStyle(color: Colors.white)),
      centerTitle: true,
      backgroundColor: Color.fromARGB(242, 5, 15, 37), // Adjust opacity as needed
      actions: [

      IconButton(
      icon: Icon(Icons.check, color: Colors.white),
      onPressed: () async {

      // Handle validation logic here
      int totalPrice = 0; // Initialize total price
      for (final item in selectedItems) {

      final String productId = item['product_id'];
      final int quantityController = item['quantityController'];

      try {

      DocumentSnapshot snapshot = await _firestore.collection('stocks').doc(productId).get();

      if (snapshot.exists) {
      final String? quantiteString = (snapshot.data() as Map<String, dynamic>?)?['quantite']?.toString();
      final int? currentQuantite = quantiteString != null ? int.tryParse(quantiteString) : null;

      Map<String, dynamic> currentPrixUnitaire = snapshot.data() as Map<String, dynamic>? ?? {}; // Handle null values gracefully
      String? priceUnit = currentPrixUnitaire['prix_unitaire'];

      int? nbre_b = currentPrixUnitaire['nbre_bouteille'];
      int? nbre_c = currentPrixUnitaire['nbre_casier'];

      if(quantityController != null && nbre_b != null && nbre_b > quantityController) {
        int nbre_bouteille_restant = nbre_b - quantityController;
        final int quantite_restant = currentQuantite != null ? currentQuantite - quantityController : 0;

        await _firestore.collection('stocks').doc(productId).update({
          'nbre_bouteille': nbre_bouteille_restant
      });

      print('Le nbre des bouteilles disponible est bien superieur à la quantité demandé, et le reste est bien ${nbre_bouteille_restant}');

      } else if(nbre_c != null && nbre_c > 0) {

      int parsedValue = int.parse(item["nbre_boissons"]!.toString());
      nbre_b = nbre_b! + parsedValue; // Cast nbre_b to non-nullable and perform addition

      int reste_nbre_c = nbre_c - 1;

      int nbre_bouteille_restant_bis = nbre_b - quantityController;
      await _firestore.collection('stocks').doc(productId).update({
        'nbre_bouteille': nbre_bouteille_restant_bis
      });

      await _firestore.collection('stocks').doc(productId).update({
        'nbre_casier': reste_nbre_c
      });

      print('Nouveau stock bouteilles => ${nbre_b}, les rest est bien ${nbre_bouteille_restant_bis}');

      } else {
        print('La quantite demandé est supérieur au nbre de bouteilles disponible');
      }

      int? finalPrice;

      // finalPrice = int.parse(priceUnit);
      if (priceUnit != null) {
        try {
        finalPrice = int.parse(priceUnit);
          } catch (e) {
            // Handle parsing error
            // print('Error parsing price: $e');
          }
        }

      totalPrice += quantityController * (finalPrice ?? 0); // Accumulate total price

      } else {
        print('Document does not exist');
      }

      } catch (error) {
        print('Error retrieving document: $error');
      }

      }

      DateTime now = DateTime.now();
      FirebaseFirestore.instance.collection('commandes').add({
        'date': now,
        'total': totalPrice,
        // 'num_table': _selectedDropdownTable,
        'num_table': 2,
        'status': 'ok',
      });

       Navigator.push(context, MaterialPageRoute(builder: (context) => Dashboard()));
      },
      ),

      IconButton(
        icon: Icon(Icons.cancel, color: Colors.white),
        onPressed: () {
          print('Commande canceled ...');
        },
      ),

      IconButton(
        icon: Icon(Icons.person, color: Colors.white),
        onPressed: () {
          print('Juste pour les testes ...');
        },
      ),

        ],
      ),
  body:Container(

    decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('images/243198494994_bis.webp'), // Replace with your image path
      fit: BoxFit.cover, // Adjust the fit as needed
      ),
    ),

    child: Column (
    children: <Widget> [
    SizedBox(height: 20),
    Center ( // Replaced Container with Center
    child: Container (
    // width: 300, // Set the desired width
    decoration: BoxDecoration(
        // color: Colors.blue, // Set background color to blue
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(40), // Set border radius
    ),

    width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
    height: 55, // Set the desired height
    child: StreamBuilder<QuerySnapshot> (
    stream: _usersStream,
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

    if (snapshot.hasError) {
      return Text('Something went wrong');
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text("Loading");
    }

    List<DropdownMenuItem<String>> dropdownItems = [];

    dropdownItems.add(DropdownMenuItem(child: Text('Selectionnez une table'), value: null)); // Add a default item
    snapshot.data!.docs.forEach((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
      String? id_doc = document.id;
      dropdownItems.add(DropdownMenuItem (
        child: Text(data['libelle'], 
        style: TextStyle (
          // color: Colors.white
           color: data['libelle'] == _selectedDropdownTable ? Colors.white : Colors.black,
        )), 
        value: id_doc));
    });

    return DropdownButtonFormField <String> (

    items: dropdownItems,

    onChanged: (value) {
      // Handle dropdown selection
      setState(() {
        _selectedDropdownTable = value as String? ?? ''; // Update the selected value
      });
    },

    value: _selectedDropdownTable,
    hint: Text('Select an item'), // Optional hint text
    decoration: InputDecoration(
      border: OutlineInputBorder (
        borderRadius: BorderRadius.circular(40),
      ),
    ),

    // style: TextStyle(color: Colors.white), // Set the text color of the selected value
    );

    },
    ),
    ),

    ),

    SizedBox(height: 20),

    Expanded(
    child: Center( // Ensuring CircularProgressIndicator is centered
    child: Container(
    child: ListView.builder(
    itemCount: boissons.length,
    itemBuilder: (BuildContext context, int index) {
    // Wrap each ContactItem with a Container for styling
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      height: 60.0,
      decoration: BoxDecoration(
      color: Colors.black87.withOpacity(0.8),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
      ),
      child: Center(
        child: ContactItem(
        boisson: boissons[index],
        showCustomDialog: showCustomDialog,
        onSelect: handleBoissonSelection,
        onItemSelected: (productId, onSelect) {
          productCustomId = productId;
        },
        updateTotalResult: updateTotalResult,
      ),
      ),
    );
  },
),

      ),
      )
      )
    ],
    ),

      ),
    );
  }
}

class ContactItem extends StatelessWidget {

  final BoissonModel boisson;
  final Future<void> Function(BuildContext, String, String, String, String, Function(int, String)) showCustomDialog;
  final Function(BoissonModel) onSelect;
  final Function(String, bool) onItemSelected;
  final Function(int) updateTotalResult;

  const ContactItem({
    required this.boisson,
    required this.onSelect,
    required this.showCustomDialog,
    required this.onItemSelected,
    required this.updateTotalResult,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
    leading: CircleAvatar(
    backgroundColor: Colors.green[700],
    child: ClipOval(
      child: Image.network(
        boisson.product_image, // Assuming boisson.product_image contains the image URL
        fit: BoxFit.cover,
        width: 40.0,
        height: 40.0,
      ),
    ),
    // child: Icon(Icons.person_outline_outlined, color: Colors.white),
    ),

    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(boisson.name, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
        Text('${boisson.phoneNumber} F', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
      ],
    ),
    // subtitle: const Text('Tap here for Hero transition'),

    trailing: IconButton(
      icon: boisson.isSelected
          ? Icon(Icons.check_circle, color: Colors.green[700])
          : Icon(Icons.check_circle_outline, color: Colors.grey),
      onPressed: () {
          onSelect(boisson); // Call the callback function
        if (boisson.isSelected) {

          showCustomDialog(context, boisson.name, boisson.productId, boisson.nbre_boissons, boisson.phoneNumber, (quantity, productId) {
            // Handle the callback if needed
          });

          onItemSelected(boisson.productId, true);

        } else {

          onItemSelected(boisson.productId, false);

        }

        // onSelect(boisson); // Call the callback function
        
      },
    ),
    );
  }
}
