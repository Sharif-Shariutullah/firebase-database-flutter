import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firbase/service/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyWidgetState();
}

final FirestoreService fs = FirestoreService();
final TextEditingController txc = TextEditingController();

class _MyWidgetState extends State<MyHomePage> {
  void openNoteBox(String? docId) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: txc,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docId == null) {
                        fs.addNote(txc.text);
                      } else {
                        fs.updateNote(docId, txc.text);
                      }

                      txc.clear();
                      //close the box
                      Navigator.pop(context);
                    },
                    child: const Text("Add"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FireBase!!",
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: fs.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String dockId = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                String noteText2 = data['timestamp'].toString();

                return ListTile(
                    title: Text(noteText),
                    subtitle: Text(noteText2),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => openNoteBox(dockId),
                          icon: Icon(Icons.settings),
                        ),
                        IconButton(
                            onPressed: () {
                              fs.deleteNode(dockId);
                            },
                            icon: Icon(Icons.delete))
                      ],
                    ));
              },
            );
          } else {
            return const Text("No Notes founds");
          }
        },
      ),
    );
  }
}
