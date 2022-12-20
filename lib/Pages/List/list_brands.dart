import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'list_products_in_brand.dart';

class ListBrands extends StatefulWidget {
  @override
  _ListBrandsState createState() => _ListBrandsState();
}

class _ListBrandsState extends State<ListBrands> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.blueAccent),
        elevation: 0.0,
        title: Text("List of Brands", style: TextStyle(color:Colors.blueAccent, fontSize: 18.0),),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("brands").snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
            return Text("No brands exist");
          }else{
            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: showListBrands(snapshot),
            );
          }
        },
      ),
    );
  }

  showListBrands(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs.map((DocumentSnapshot document)=>
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ListProductsInBrand(brand: document["brandName"])));
              },
              leading: Image.network(document["brandImage"], width: 90, height: 50,),
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(document["brandName"], style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        )
    ).toList();
  }
}


