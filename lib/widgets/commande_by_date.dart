import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommandeListByDate extends StatefulWidget {
  const CommandeListByDate({Key? key}) : super(key: key);

  @override
  State<CommandeListByDate> createState() => _CommandeListViewState();
}

class _CommandeListViewState extends State<CommandeListByDate> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int totalResult = 0;
  int sumtotal = 0;
  String productCustomId = "";
  List<Map<String, dynamic>> selectedItems = [];
    late String appBarTitle = '';

  // late String appBarTitle;

  @override
  void initState() {
    super.initState();
    // appBarTitle = 'Total: $totalResult FCFA';
    getDatabis();
  }

  void updateSelectedItems(String productId, int quantity) {
    setState(() {
      selectedItems.add({
        'product_id': productId,
        'quantityController': quantity,
      });
    });
  }

  void updateAppBarTitle() {
    setState(() {
      appBarTitle = 'Total: $totalResult FCFA';
    });
  }

  void updateTotalResult(int newTotal) {
    setState(() {
      totalResult = newTotal;
    });
  }

  Future<void> getDatabis() async {
  int sumtotal = 0;

    // Retrieve all documents from the "commandes" collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('commandes')
        .orderBy('date', descending: true)
        .get();

    // Iterate through each document and aggregate the total for each date
    querySnapshot.docs.forEach((doc) {
      Timestamp timestamp = doc['date'] ?? Timestamp.now(); // Providing a default Timestamp if 'date' is null
      DateTime date = timestamp.toDate();
      String formattedDate = '${date.year}-${date.month}-${date.day}'; // Format date as string

      int total = doc['total'] ?? 0; // Providing a default value of 0 if 'total' is null

      sumtotal += total;
    });

    setState(() {
      appBarTitle = 'Total: $sumtotal FCFA';
    });
  }

  Future<List<Map<String, dynamic>>> getData() async {
    QuerySnapshot querySnapshot = await _firestore.collection('commandes')
    .orderBy('date', descending: true)
    .get();

    List<Map<String, dynamic>> data = [];
    
      await Future.forEach(querySnapshot.docs, (doc) async {

      String orderId = doc.id;
      Timestamp timestamp = doc['date'];
      DateTime dateTime = timestamp.toDate();
      String orderDate = DateFormat('dd/MM/yyyy').format(dateTime);
      String orderNumTable = doc['num_table'].toString();
      String productImageUrl = doc.id;
      String orderTotal = doc['total'].toString() ?? '';

      String? numTable;
      // DocumentSnapshot querySnapshot_bis = _firestore.collection('rest_tables').doc(orderNumTable).get();
      DocumentReference doc_ref = _firestore.collection("rest_tables").doc(orderNumTable);
      DocumentSnapshot docSnap = await doc_ref.get();

      if (docSnap.exists) {
        numTable = docSnap['numero'];
      } else {
        numTable = orderNumTable;
      }

      Map<String, dynamic> productData = {
        'product_id': orderId,
        'num_table': numTable,
        'date_commande': orderDate,
        'total_commande': orderTotal,
      };

      data.add(productData);

    });

    return data;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
    appBar: AppBar(
    backgroundColor: Color.fromARGB(242, 5, 15, 37), // Adjust opacity as needed
    title: Text(appBarTitle, style: TextStyle(color: Colors.white)),
    actions: [
    IconButton(
      icon: Icon(Icons.check),
      onPressed: () {

        for(final linec in selectedItems) {
          // print("Id produit ${linec["product_id"]}. Et la quantité choisie est bien ${linec["quantityController"]}");
        }
        
        // Handle validation logic here
      },
    ),
    IconButton(
      icon: Icon(Icons.cancel),
      onPressed: () {
        print('Commande canceled ...');
      },
    ),
    IconButton(
      icon: Icon(Icons.person),
      onPressed: () {
        print('Juste pour les testes ...');
      },
    ),
    ],
    ),
    body: Container(

      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/243198494994_bis.webp'), // Replace 'assets/background_image.jpg' with your image path
          fit: BoxFit.cover,
        ),
      ),

      child: FutureBuilder<List<Map<String, dynamic>>>(

    future: getData(),
    builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {

    List<Map<String, dynamic>> data = snapshot.data!;
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Column(
          
                  children: [
                    CustomListTile(
                      productId: data[index]['num_table'],
                      title: data[index]['total_commande'] + ' FCFA',
                      subtitle: data[index]['date_commande'],
                      image: data[index]['total_commande'],
                      value: selectedItems.contains(data[index]), // Check if item is selected
                      totalResult: totalResult,
                      updateTotalResult: updateTotalResult,
                      updateAppBarTitle: updateAppBarTitle,
                      selectedItems: selectedItems,
                      addItemsToArray: (productId, quantity) {
                          updateSelectedItems(productId, quantity);
                      },
                      onChanged: (bool? value) {
                        // Handle checkbox changes if needed
                      },
                      onItemSelected: (productId, isSelected) {
                        productCustomId = productId;


                        print('Product ID: $productId is selected: $isSelected');
                      },
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              },
            );
          }
        },
      ),

    )
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final bool value;
  final Function(bool?) onChanged;
  final int totalResult;
  final Function(int) updateTotalResult;
  final VoidCallback updateAppBarTitle;
  final void Function(String productId, int quantity) addItemsToArray;
  final String productId;
  final Function(String, bool) onItemSelected;
  final List<Map<String, dynamic>> selectedItems;

  const CustomListTile({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.value,
    required this.onChanged,
    required this.totalResult,
    required this.updateTotalResult,
    required this.updateAppBarTitle,
    required this.productId,
    required this.onItemSelected,
    required this.selectedItems,
    required this.addItemsToArray,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      // color: Colors.blue, // Background color for the ListTile
      padding: EdgeInsets.all(8.0), // Padding around the content
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ],
        ),
        leading: FutureBuilder(
          future: precacheImage(NetworkImage(image), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Icon(Icons.error);
            } else {
              return ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  height: 100,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blueGrey.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      'T°' + productId,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
        trailing: Checkbox(
          value: value,
          onChanged: (bool? newValue) {
            onChanged(newValue);
            if (newValue != null) {
              if (newValue) {
                onItemSelected(productId, true);
              } else {
                onItemSelected(productId, false);
              }
            }

            if (newValue == true) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController quantityController = TextEditingController();
                  return AlertDialog(
                    title: const Text('Basic dialog title'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Bonjour $title'),
                        Text('Je rends grâce à Dieu mon roi $subtitle'),
                        SizedBox(height: 16.0),
                        Text('Enter quantity:'),
                        TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          String quantityText = quantityController.text;
                          int quantity = int.tryParse(quantityText) ?? 0;
                          int totalPrice = quantity * int.parse(subtitle);

                          updateTotalResult(totalResult + totalPrice);
                          updateAppBarTitle();

                          addItemsToArray(productId, quantity);

                          print('Total Price: $totalPrice');
                          Navigator.of(context).pop();
                        },
                        child: Text('Valider'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
