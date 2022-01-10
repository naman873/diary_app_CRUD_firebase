import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personal_diary_app_project/add_screen.dart';

import 'package:intl/intl.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<String> dummyList = ["abc", "def"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Screen",
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const AddScreen();
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              20,
            ),
            color: Colors.indigo,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: const Text(
            "Add Today Thoughts",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("dairy2022")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                //print("snapshot $snapshot");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Text("SOMETHING WENT WRONG");
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Record",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data!.docs[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(width: 0.2),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Title : ${item['title']}"),
                              IconButton(
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AddScreen(
                                          id: item.id,
                                          title: item['title'],
                                          content: item['content'],
                                          date: item['date'].toDate(),
                                          tags: item['tags'],
                                        );
                                      },
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.app_registration_rounded,
                                  color: Colors.pinkAccent,
                                ),
                              )
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tags : ${item["tags"]}"),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Content : ${item["content"]}"),
                                  Text(
                                    "Date : ${DateFormat("dd-MMM-yyyy").format(item["date"].toDate())}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onLongPress: () {
                            FirebaseFirestore.instance
                                .collection("dairy2022")
                                .doc(item.id)
                                .delete()
                                .then((value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text("Item Deleted"),
                                duration: Duration(seconds: 1),
                              ));
                            }).onError((error, stackTrace) {
                              const SnackBar(
                                content: Text("SOMETHING WENT WRONG"),
                                duration: Duration(seconds: 1),
                              );
                            });
                          },
                        ),
                      );
                    },
                  );
                }
                return const Text("Loading");
              },
            ),
          )
        ],
      ),
    );
  }
}

// FutureBuilder<QuerySnapshot>(
// future: FirebaseFirestore.instance.collection("dairy2022").get(),
// builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
// if (snapshot.connectionState == ConnectionState.waiting) {
// return const Center(
// child: CircularProgressIndicator(),
// );
// }
// if (snapshot.hasError) {
// return const Text("SOMETHING WENT WRONG");
// }
// if (snapshot.connectionState == ConnectionState.done) {
// return ListView.builder(
// itemCount: snapshot.data!.docs.length,
// itemBuilder: (context, index) {
// var item = snapshot.data!.docs[index];
// return Container(
// margin: const EdgeInsets.symmetric(
// vertical: 5.0, horizontal: 12.0),
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(4.0),
// border: Border.all(width: 0.2),
// ),
// child: ListTile(
// title: Text("Title : ${item['title']}"),
// subtitle: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text("Tags : ${item["tags"]}"),
// Row(
// mainAxisAlignment:
// MainAxisAlignment.spaceBetween,
// children: [
// Text("Content : ${item["content"]}"),
// Text(
// "Date : ${item["date"]}",
// style: const TextStyle(
// fontSize: 12,
// ),
// ),
// ],
// ),
// ],
// ),
// ),
// );
// },
// );
// }
// return const Text("Loading");
// },
// ),

// Image.file(
//   File("${item["image"]}"),
//   height: 100,
//   width: 100,
//   errorBuilder:
//       (BuildContext, Object, StackTrace) {
//     return const Icon(Icons.ten_k);
//   },
// ),
