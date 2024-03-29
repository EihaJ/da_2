import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detailorder.dart';

class Product {
  List products;
  Product.fromMap(Map<String, dynamic> data) {
    products = data['products'];
  }
}

class ProductR {
  List products = new List();
  ProductR.fromSnapshot(DocumentSnapshot snapshot)
      : products = List.from(snapshot["products"]);
}

class MyOrder extends StatefulWidget {
  final String email;
  MyOrder({Key key, @required this.email}) : super(key: key);
  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  Timestamp timeAgo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: Text("My Order"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("orders").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("No products in cart yet!");
                  } else {
                    return Container(
                      child: ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: _showItemInOrder(snapshot),
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  _showItemInOrder(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> data = new List();
    for (DocumentSnapshot document in snapshot.data.docs) {
      if (document["informationPersonal"]["email"] == widget.email) {
        data.add(document);
      } else {
        _noProducts();
      }
    }
    return data.map((DocumentSnapshot document) {
      timeAgo = document["time"];
      return Card(
        elevation: 5.0,
        child: ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailOrder(
                          orderId: document["orderId"],
                        )));
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Time to order: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(timeAgo.toDate().toString(),
                      style: TextStyle(
                        fontSize: 18,
                      )),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: <Widget>[
                  Text(
                    "Status: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  document["status"]
                      ? Text("Delivered",
                          style: TextStyle(
                            fontSize: 18,
                          ))
                      : Text("Not Delivery",
                          style: TextStyle(
                            fontSize: 18,
                          ))
                ],
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _noProducts() {
    return Padding(
      padding: const EdgeInsets.only(top: 150.0),
      child: Container(
        alignment: Alignment.center,
        child: Center(
          child: Text("You haven't favourite products yet"),
        ),
      ),
    );
  }
}
