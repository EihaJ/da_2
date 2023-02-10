import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'list_product_in_category.dart';

class ListCategories extends StatefulWidget {
  @override
  _ListCategoriesState createState() => _ListCategoriesState();
}

class _ListCategoriesState extends State<ListCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        title: Text(
          "List of Categories",
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Categories").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text("No categories exist");
          } else {
            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: showListCategories(snapshot),
            );
          }
        },
      ),
    );
  }

  showListCategories(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((DocumentSnapshot document) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListProductsInCategory(
                                category: document["categoryName"])));
                  },
                  leading: Image.network(
                    document["categoryImage"],
                    width: 100,
                    height: 100,
                  ),
                  title: Text(
                    document["categoryName"],
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ))
        .toList();
  }
}
