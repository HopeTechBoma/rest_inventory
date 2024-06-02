import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rest_inventory/widgets/add_article.dart';
import 'package:rest_inventory/widgets/show_items.dart';
import 'package:rest_inventory/widgets/list_commandes.dart';
import 'package:rest_inventory/widgets/commande_by_date.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

  class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getData() async {
    QuerySnapshot querySnapshot = await _firestore.collection('stocks').get();
  
    List<Map<String, dynamic>> data = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>? ?? {}; // Handle null values gracefully
      String? categorieId = docData['id_boisson'];
      String? product_in_stock_id = doc.id;

      if (categorieId != null) {
        DocumentSnapshot categorieSnapshot = await _firestore.collection('categorie_boissons').doc(categorieId).get();
      
        if (categorieSnapshot.exists) {
          Map<String, dynamic>? productCategorieData = categorieSnapshot.data() as Map<String, dynamic>?; // Handle null values gracefully
        
          if (productCategorieData != null) {
          String? productCategoriesUrl = productCategorieData['prod_image_url'];
          String? categorie_libelle = productCategorieData['appellation'];

          if (productCategoriesUrl != null && categorie_libelle != null) {
          data.add({
            'prix_unitaire': docData['prix_unitaire'],
            'product_categories_url': productCategoriesUrl,
            'categorie_libelle': categorie_libelle,
            'stocks_bouteille': docData['nbre_bouteille'],
            'product_in_stock_id': product_in_stock_id,
            'stocks_casier': docData['nbre_casier'],
          });
            }
          }
        }
      }
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getDataByDateRange(DateTime startDate, DateTime endDate) async {
    QuerySnapshot querySnapshot = await _firestore
      .collection('commandes')
      .where('date', isGreaterThanOrEqualTo: startDate)
      .where('date', isLessThanOrEqualTo: endDate)
      .get();

       print("Number of documents for today: ${querySnapshot.docs.length}");

    List<Map<String, dynamic>> data = [];

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
      // Assuming 'total' is the field representing the revenue in each document
      double totalValue = (docData['total'] ?? 0).toDouble(); // Use 'num' type to handle both 'int' and 'double'

      data.add({
        'total': totalValue,
      });
    }

    return data;
  }

  Future<double> getTotalRevenue(DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> transactions = await getDataByDateRange(startDate, endDate);
    double totalRevenue = 0.0; // Use double type for totalRevenue
    for (var transaction in transactions) {
      totalRevenue += (transaction['total'] ?? 0).toDouble(); // Convert to double
    }
    return totalRevenue;
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  backgroundColor: Color.fromARGB(242, 5, 15, 37), // Adjust opacity as needed
  title: Text(
    'Tableau de bord',
    style: TextStyle(color: Colors.white)
  ),

  actions: [

    IconButton (
    icon: Icon(Icons.post_add_rounded, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ItemListView()),
      );
    },
  ),

  IconButton (
  icon: Icon(Icons.add_circle_outline, color: Colors.white),
  onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddArticles()),
      );
    },
  ),

  IconButton (
    icon: Icon(Icons.border_color_outlined, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommandeListByDate()),
      );
    },
  ),

  IconButton (
    icon: Icon(Icons.monetization_on_outlined, color: Colors.white),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommandeListView()),
      );
    },
  ),

  ],

  ),

  body: Container (
    // color: Color.fromRGBO(0, 0, 0, 0.7), // White color with 50% transparency
    decoration: BoxDecoration (
      image: DecorationImage (
        image: AssetImage('images/243198494994_bis.webp'), // Replace with your image path
        fit: BoxFit.cover, // Adjust the fit as needed
      ),
    ),

    child: Column (
    crossAxisAlignment: CrossAxisAlignment.start,

    children: [
    Padding (
    padding: const EdgeInsets.all(8.0),
    child: Row (
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    Expanded (
      flex: 1, // Adjust the flex value as needed
      child: DashboardCard (
        title: 'Aujourd\'hui',
        futureBuilder: () => getTotalRevenue(
          DateTime.now().subtract(Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
            milliseconds: DateTime.now().millisecond,
            microseconds: DateTime.now().microsecond,
          )),
          DateTime.now().add(Duration(days: 1)).subtract(Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
            milliseconds: DateTime.now().millisecond,
            microseconds: DateTime.now().microsecond,
          )),
        ),
        icon: Icons.access_alarm,
      ),
    ),
    Expanded(
      flex: 1, // Adjust the flex value as needed
      child: DashboardCard(
        title: 'Semaine',
        futureBuilder: () => getTotalRevenue(
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
          DateTime.now(),
        ),
        icon: Icons.access_time,
      ),
    ),
    Expanded(
      flex: 1, // Adjust the flex value as needed
      child: DashboardCard(
        title: 'Ce Mois',
        futureBuilder: () => getTotalRevenue(
          DateTime(DateTime.now().year, DateTime.now().month, 1),
          DateTime.now(),
        ),
        icon: Icons.accessibility,
      ),
    ),
  ],
)

  ),

  SizedBox(height: 20),

  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      'Stock disponible',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),

  ),

  Expanded(

  child: Container(
  child: FutureBuilder<List<Map<String, dynamic>>>(
  future: getData(),
  builder: (context, snapshot) {

  if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  if (snapshot.hasError) {
    return Center(
      child: Text('Error: ${snapshot.error}'),
    );
  }

  final List<Map<String, dynamic>> products = snapshot.data ?? [];
  return ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {

 final product = products[index];

 return Container(

    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    height: 60.0,
    decoration: BoxDecoration(
      color: Colors.black87.withOpacity(0.5),
      borderRadius: BorderRadius.circular(15.0),
    ),
      
    child: Center(
    child: ListTile(

    leading: CircleAvatar(
      backgroundImage: NetworkImage(product['product_categories_url']),
    ),

    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          product['categorie_libelle'].toString(),
          style: TextStyle(color: Colors.white),
        ), // Not sure what you want to display here
        Text(
          '${product['stocks_casier'].toString()}  Casiers & ${product['stocks_bouteille'].toString()} B.',
          style: TextStyle(color: Colors.white),
        ), // Assuming 'quantite' is the stock data field
      ],
    ),

    trailing: Container(
    decoration: BoxDecoration(
      color: Colors.green, // Set button background color here
      borderRadius: BorderRadius.circular(20), // Optional: You can adjust the border radius
    ),

    constraints: BoxConstraints(
      maxWidth: 30, // Set maximum width here
      maxHeight: 30, // Set maximum height here
    ),

    child: SizedBox(
    height: 30.0, // Set desired height
    width: 30.0, // Set desired width
    child: IconButton(
    padding: EdgeInsets.all(0.0),
    iconSize: 20, // Set the size of the icon
    icon: Icon(Icons.add, color: Colors.white), // Set icon color here
    
    onPressed: () {

    String product_id = product['product_in_stock_id'];
    int nbre_c_bis = product['stocks_casier'];
    int nbre_b_bis = product['stocks_bouteille'];

    showDialog(
    context: context,
    builder: (BuildContext context) {

    TextEditingController nbre_caController = TextEditingController();
    TextEditingController nbre_bController = TextEditingController();

    return AlertDialog(
    title: Center(
      child: Text('${product['categorie_libelle'].toString()}')
    ),
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [

    TextField(
      controller: nbre_caController,
      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
      ],
      decoration: InputDecoration(
        labelText: 'Nombre des casiers',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      // decoration: InputDecoration(labelText: 'Entrez la quantité'),
    ),

    SizedBox(height: 20),

    TextField(
      controller: nbre_bController,
      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
      ],
      decoration: InputDecoration(
        labelText: 'Nombre des bouteilles',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      // decoration: InputDecoration(labelText: 'Entrez la quantité'),
    ),

    ],
  ),

        actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 8), // Adjust spacing if needed
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                ),
                child: Text(
                  'Annuler',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
              onPressed: () async {
                String nbre_casierText = nbre_caController.text;
                String nbre_bText = nbre_bController.text;

                int nbre_casierText_converted =
                    int.tryParse(nbre_casierText) ?? 0;
                int nbre_bText_converted = int.tryParse(nbre_bText) ?? 0;

                int total_c = nbre_casierText_converted + nbre_c_bis;
                int total_b = nbre_bText_converted + nbre_b_bis;

                await _firestore.collection('stocks').doc(product_id).update({
                  'nbre_bouteille': total_b,
                  'nbre_casier': total_c
                });

                setState(() {});

                Navigator.of(context).pop(); // Close the dialog

                print('Nbre casier ${total_c} and nbre b ${total_b}');
              },
              child: Text(
                'Valider',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],


  );
  }
  );
  },
  ),
  ),
  ),

  ),
      ),


      );
  },
  );
  },
  ),
    ),
  ),
  ],
  ),
  ),
  );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<double> Function() futureBuilder;

  DashboardCard({required this.title, required this.icon, required this.futureBuilder});

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 5,
      child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(

      children: [
        Icon(
          icon,
          size: 40,
          color: Colors.blue,
        ),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(fontSize: 18),
        ),

        SizedBox(height: 5),
        FutureBuilder<double>(

        future: futureBuilder(),
        builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        return Text(
          '${snapshot.data} FCFA',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        );

        },
        ),
        ],
        ),
      ),
    );
  }
}
