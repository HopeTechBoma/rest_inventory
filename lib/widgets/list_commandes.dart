import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommandeListView extends StatefulWidget {
  const CommandeListView({Key? key}) : super(key: key);

  @override
  State<CommandeListView> createState() => _CommandeListViewState();
}

class _CommandeListViewState extends State<CommandeListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int totalResult = 0;
  int sumtotal = 0;
  String productCustomId = "";
  List<Map<String, dynamic>> selectedItems = [];

  late String appBarTitle = '';

  @override
  void initState() {
    super.initState();
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
    List<Map<String, dynamic>> data = [];

    // Retrieve all documents from the "commandes" collection
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('commandes')
        .orderBy('date', descending: true)
        .get();

    // Map to store totals for each unique date
    Map<String, int> totalsByDate = {};

    // Iterate through each document and aggregate the total for each date
    querySnapshot.docs.forEach((doc) {
      Timestamp timestamp = doc['date'] ?? Timestamp.now(); // Providing a default Timestamp if 'date' is null
      DateTime date = timestamp.toDate();
      String formattedDate = '${date.year}-${date.month}-${date.day}'; // Format date as string

      int total = doc['total'] ?? 0; // Providing a default value of 0 if 'total' is null

      // Aggregate the total for each date
      if (totalsByDate.containsKey(formattedDate)) {
        totalsByDate[formattedDate] = (totalsByDate[formattedDate] ?? 0) + total;
      } else {
        totalsByDate[formattedDate] = total;
      }

      sumtotal += total;
    });

    // Convert the aggregated data into the desired format
    totalsByDate.forEach((date, total) {
      data.add({
        'date': date,
        'totalsum': total,
      });
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> data = snapshot.data!;

            return ListView.builder(
  itemCount: data.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add padding here
            leading: ClipRect(
              child: Container(
                height: 100,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  // color: Colors.green,
                  color: Colors.brown.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    'N°${index + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${data[index]['totalsum']} FCFA",
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                ),
                Text(
                  data[index]['date'].toString(),
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: false,
              onChanged: (bool? newValue) {
                // onChanged(newValue);
              },
            ),
          ),
        ),
        SizedBox(height: 16.0),
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
