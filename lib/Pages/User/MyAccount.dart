import 'package:flutter/material.dart';
import '../Cart/CartPage.dart';

class MyAccount extends StatefulWidget {
  final String email;
  MyAccount({Key key, @required this.email}) : super(key: key);
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: unnecessary_new
      appBar: new AppBar(
        backgroundColor: Colors.cyan,
        title: Text("Account"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CartPage(email: widget.email,)));
              }),
        ],
      ),
    );
  }
}
