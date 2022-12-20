import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CommentPage extends StatefulWidget {
  final String email;
  final String id;
  final String name;
  CommentPage({Key key, @required this.id, this.email, this.name})
      : super(key: key);
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TextEditingController _commentController = TextEditingController();
  Uuid uuid = Uuid();
  Timestamp timeAgo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Comments",
          style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 20.0,
              fontWeight: FontWeight.w800),
        ),
        leading: Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.pop(context);
                })),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Name of product: ${widget.name}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection("comments").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Text("No comments for this product"),
                    ),
                  );
                } else {
                  return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        children: _showComments(snapshot),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Type your comment",
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    var time = DateTime.now();
                    FirebaseFirestore.instance
                        .collection("comments")
                        .doc(uuid.v1())
                        .set({
                      "commentId": uuid.v1(),
                      "content": {
                        "email": widget.email,
                        "productId": widget.id,
                        "comment": _commentController.text,
                        "timeComment": time
                      }
                    });
                  })
            ],
          ),
        ],
      ),
    );
  }

  _showComments(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<DocumentSnapshot> data = List();
    for (DocumentSnapshot doc in snapshot.data.docs) {
      if (doc["content"]["productId"] == widget.id) {
        data.add(doc);
      } else {
        _noProducts();
      }
    }
    return data.map((DocumentSnapshot doc) {
      timeAgo = doc["content"]["timeComment"];
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                doc["content"]["email"],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                doc["content"]["comment"],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                timeAgo.toDate().toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
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
