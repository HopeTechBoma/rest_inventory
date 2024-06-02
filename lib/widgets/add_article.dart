import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddArticles extends StatefulWidget {
  @override
  _AddArticlesState createState() => _AddArticlesState();
}

class _AddArticlesState extends State<AddArticles> {
  
  TextEditingController _textController = TextEditingController();
  TextEditingController _quantiteController = TextEditingController();
  String? _selectedDropdownValue; // State variable to hold selected value
  String? _fileDownloadURL; // Added to store the file download URL

  void  _pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {

    PlatformFile file = result.files.first;

    Reference storageReference =
    FirebaseStorage.instance.ref().child(file.name);
    UploadTask uploadTask = storageReference.putData(file.bytes!);

    // Wait for the file to upload and get the download URL
    String downloadURL =
    await (await uploadTask).ref.getDownloadURL();
        
    // Save the text and file URL to Firestore
    FirebaseFirestore.instance.collection('files').add({
      'text': _textController.text,
      'file_url': downloadURL,
      'quantite': _quantiteController.text,
    });

    // Clear the text field after uploading
    _textController.clear();

    } else {
      // User canceled the picker
    }
  }

  void _submitData() {

      FirebaseFirestore.instance.collection('stocks').add({
        'id_boisson': _selectedDropdownValue,
        // 'file_url': _fileDownloadURL,
        'quantite': _textController.text,
        'prix_unitaire': _quantiteController.text,
        'nbre_casier': int.parse(_textController.text),
        'nbre_bouteille': 0
      });

      // Clear the text fields and file URL after uploading
      _textController.clear();
      _quantiteController.clear();
      _fileDownloadURL = null;

      print('success');

  }

Future<List<Map<String, dynamic>>> fetchData() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('categorie_boissons').get();
  List<Map<String, dynamic>> data = [];

  for (DocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>? ?? {}; // Handle null values gracefully
    String? appelation = docData['libelle'];

    QuerySnapshot querySnapshot_bis = await FirebaseFirestore.instance.collection('stocks').where('id_boisson', isEqualTo: doc.id).get();
    // QuerySnapshot querySnapshot_bis = await FirebaseFirestore.instance
    // .collection('stocks')
    // .where('id_boisson', isNotEqualTo: doc.id)
    // .get();

    if (querySnapshot_bis.docs.isEmpty) {
      // Assuming you want to add the first document's ID to the data list
      data.add({
        'libelle': appelation,
        'id_produit': doc.id,
      });
    }
  }

  return data; 
}

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.white,
    primary: Colors.green[300],
    minimumSize: Size(200, 51),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
);


// String _selectedDropdownValue = ''; // Set a default value

@override
Widget build(BuildContext context) {
  
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(242, 5, 15, 37), // Adjust opacity as needed
      title: Text('Approvisionnement du stock', style: TextStyle(color: Colors.white)),
    ),
    body: Container(
      decoration: BoxDecoration (
      image: DecorationImage (
        image: AssetImage('images/243198494994_bis.webp'), // Replace with your image path
        fit: BoxFit.cover, // Adjust the fit as needed
      ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

      Container(

        constraints: BoxConstraints.expand(height: 200.0, width: 200.0),

        child: CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage('images/images_test.jpg'),
        )
      ),

      SizedBox(height: 20),

      FutureBuilder<List<Map<String, dynamic>>>(

      future: fetchData(),
      builder: (context, snapshot) {

      if(snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      if(snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      List<DropdownMenuItem<String>> clientItems = [];

      final clients = snapshot.data!;

          for(var client in clients) {
            clientItems.add(DropdownMenuItem(
              value: client['id_produit'],
              child: Text(client['libelle']),
            ));
          }

          return DropdownButtonFormField(
            items: clientItems,
            onChanged: (clientValue) {
              setState(() {
                _selectedDropdownValue = clientValue as String? ?? ''; // Update the selected value
              });
            },

            value: _selectedDropdownValue, // Set the value to the selected value
            hint: Text('Selectionnez une boisson'), // Optional hint text

            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            
          );
          },
        ),

        SizedBox(height: 20),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: 'Entrez la quantité',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            style: TextStyle(color: Colors.white),
            // decoration: InputDecoration(labelText: 'Entrez la quantité'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _quantiteController,
            decoration: InputDecoration(
              labelText: 'Entrez le prix',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            style: TextStyle(color: Colors.white),
            // decoration: InputDecoration(labelText: 'Entrez le prix'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitData,
            child: Text('Enregistrer'),
            style: raisedButtonStyle
          ),
        ],
      ),
    ),
        ],
      ),

    )
  );
}

}
