import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:avataaar_image_2/avataaar_image_2.dart';
import 'package:carousel_pro/carousel_pro.dart';
import '../Pages/Cart/CartPage.dart';
import '../Pages/Product/ProductDetails.dart';
import '../Pages/User/LoginPage.dart';
import '../Pages/List/list_favourite.dart';
import '../Pages/List/list_products_in_brand.dart';
import '../Pages/Order/myorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import '../Components/FeaturedProduct.dart';
import '../Components/saleProduct.dart';
import '../db/product.dart';
import '../db/sliders.dart';
import '../Pages/List/list_product_in_category.dart';
import '../Pages/List/list_categories.dart';
import '../Pages/List/list_brands.dart';
import '../Components/DisplayrecentProducts.dart';
import 'package:badges/badges.dart';
import 'User/MyAccount.dart';

class HomePage extends StatefulWidget {
  final User user;
  HomePage({Key key, @required this.user}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  List<DocumentSnapshot> _sliders = <DocumentSnapshot>[];
  List<DocumentSnapshot> _products = <DocumentSnapshot>[];

  ProductServices _productServices = ProductServices();
  SlidersServices _slidersServices = SlidersServices();

  List imagesList;
  int total = 0;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final facebookLogin = FacebookLogin();

  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String ref = "users";

  TextEditingController _searchController = TextEditingController();

  Future<Null> signOut() async {
    // Sign out with firebase
    firebaseAuth.signOut();
    // Sign out with google
    // UserCredential result = await firebaseAuth.signInWithEmailAndPassword(
    //     email: _emailEditingController.text,
    //     password: _passwordEditingController.text
    // );
    // User user = result.user;
    // FirebaseFirestore.instance.collection("users").doc(user.uid).update({
    //   "isLoggedIn" : false
    // });
    // await googleSignIn.signOut();
    //Sign out with Facebook
    // await facebookLogin.logOut();
    Fluttertoast.showToast(
        msg: "Signed out successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSliders();
    _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    //Slider
    // ignore: unnecessary_new
    Widget imageCarousel = new Container(
      height: 150,
      child: InkWell(
        onTap: () {},
        child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: _showImageInCarousel()),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 350) {
          return Scaffold(
            appBar: new AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0.0,
              title: Text(
                "Le Livre",
              ),
              centerTitle: true,
              backgroundColor: Colors.blue,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartPage(
                                    email: widget.user.email,
                                  )));
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("carts")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("0");
                        } else {
                          return Badge(
                            badgeContent: _showQuantity(snapshot),
                            child: Icon(Icons.shopping_cart),
                            position: BadgePosition.topStart(top: 5, start: 15),
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            drawer: new Drawer(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.user.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("No info");
                    } else {
                      return _showInForUser(snapshot.data);
                    }
                  }),
            ),
            body: Container(
              color: Colors.white70,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Divider(),
                  Material(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: ListTile(
                        title: TextFormField(
                          onTap: () {
                            showSearch(
                                context: context, delegate: DataSearch());
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            hintText: "What are you shopping for today?",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: imageCarousel,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Categories")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Categories exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewCategories(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Brands',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("brands")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Brands exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewBrands(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Featured products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  FeaturedProducts(),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Sale products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  SaleProducts(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Recent products',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ),
                  RecentProducts(),
                ],
              ),
            ),
            bottomNavigationBar: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                    elevation: 10.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListCategories()));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.category,
                            color: Colors.black,
                          ),
                          Text(
                            "Categories",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListBrands()));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.label,
                            color: Colors.black,
                          ),
                          Text(
                            "Brands",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListProductsFavourite(
                                    email: widget.user.email)));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.favorite,
                            color: Colors.black,
                          ),
                          Text(
                            "Favourite",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10.0,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartPage(
                                      email: widget.user.email,
                                    )));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                          ),
                          Text(
                            "Cart",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (constraints.maxWidth > 351 && constraints.maxWidth < 410) {
          return Scaffold(
            appBar: new AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              elevation: 0.0,
              title: Text(
                "Le Livre",
              ),
              centerTitle: true,
              backgroundColor: Colors.blue,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartPage(
                                    email: widget.user.email,
                                  )));
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("carts")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("0");
                        } else {
                          return Badge(
                            badgeContent: _showQuantity(snapshot),
                            child: Icon(Icons.shopping_cart),
                            position: BadgePosition.topStart(top: 5, start: 15),
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            drawer: new Drawer(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.user.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("No info");
                    } else {
                      return _showInForUser(snapshot.data);
                    }
                  }),
            ),
            body: Container(
              color: Colors.white70,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Divider(),
                  Material(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: ListTile(
                        title: TextFormField(
                          onTap: () {
                            showSearch(
                                context: context, delegate: DataSearch());
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            hintText: "What are you shopping for today?",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: imageCarousel,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Categories")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Categories exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewCategories(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Brands',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("brands")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Brands exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewBrands(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Featured products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  FeaturedProducts(),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Sale products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  SaleProducts(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Recent products',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ),
                  RecentProducts(),
                ],
              ),
            ),
            bottomNavigationBar: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 98,
                    child: Card(
                      elevation: 10.0,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListCategories()));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.category,
                              color: Colors.black,
                            ),
                            Text(
                              "Categories",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 98,
                    child: Card(
                      elevation: 10.0,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListBrands()));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.label,
                              color: Colors.black,
                            ),
                            Text(
                              "Brands",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 98,
                    child: Card(
                      elevation: 10.0,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListProductsFavourite(
                                      email: widget.user.email)));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.favorite,
                              color: Colors.black,
                            ),
                            Text(
                              "Favourite",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 98,
                    child: Card(
                      elevation: 10.0,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartPage(
                                        email: widget.user.email,
                                      )));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.shopping_cart,
                              color: Colors.black,
                            ),
                            Text(
                              "Cart",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (constraints.maxWidth > 411 && constraints.maxWidth < 500) {
          return Scaffold(
            appBar: new AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0.0,
              title: Text(
                "Le Livre",
                style: TextStyle(color: Colors.blueAccent, fontSize: 18.0),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartPage(
                                    email: widget.user.email,
                                  )));
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("carts")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("0");
                        } else {
                          return Badge(
                            badgeContent: _showQuantity(snapshot),
                            child: Icon(Icons.shopping_cart),
                            position: BadgePosition.topStart(top: 5, start: 15),
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            drawer: new Drawer(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.user.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("No info");
                    } else {
                      return _showInForUser(snapshot.data);
                    }
                  }),
            ),
            body: Container(
              color: Colors.white70,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Divider(),
                  Material(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: ListTile(
                        title: TextFormField(
                          onTap: () {
                            showSearch(
                                context: context, delegate: DataSearch());
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            hintText: "What are you shopping for today?",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: imageCarousel,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Categories")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Categories exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewCategories(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Brands',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("brands")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Brands exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewBrands(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Featured products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  FeaturedProducts(),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Sale products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  SaleProducts(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Recent products',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ),
                  RecentProducts(),
                ],
              ),
            ),
            bottomNavigationBar: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListCategories()));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.category,
                          color: Colors.black,
                        ),
                        Text(
                          "Categories",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListBrands()));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.label,
                          color: Colors.black,
                        ),
                        Text(
                          "Brands",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListProductsFavourite(
                                  email: widget.user.email)));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          color: Colors.black,
                        ),
                        Text(
                          "Favourite",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartPage(
                                    email: widget.user.email,
                                  )));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                        ),
                        Text(
                          "Cart",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (constraints.maxWidth > 501) {
          return Scaffold(
            appBar: new AppBar(
              iconTheme: IconThemeData(color: Colors.blueAccent),
              elevation: 0.0,
              title: Text(
                "Le Livre",
                style: TextStyle(color: Colors.blueAccent, fontSize: 18.0),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartPage(
                                    email: widget.user.email,
                                  )));
                    },
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("carts")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("0");
                        } else {
                          return Badge(
                            badgeContent: _showQuantity(snapshot),
                            child: Icon(Icons.shopping_cart),
                            position: BadgePosition.topStart(top: 5, start: 15),
                          );
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
            drawer: new Drawer(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.user.uid)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("No info");
                    } else {
                      return _showInForUser(snapshot.data);
                    }
                  }),
            ),
            body: Container(
              color: Colors.white70,
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Divider(),
                  Material(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.grey.withOpacity(0.2),
                    elevation: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: ListTile(
                        title: TextFormField(
                          onTap: () {
                            showSearch(
                                context: context, delegate: DataSearch());
                          },
                          controller: _searchController,
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            hintText: "What are you shopping for today?",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: imageCarousel,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("Categories")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Categories exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewCategories(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child: Text(
                      'Brands',
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("brands")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Text("No Brands exist");
                          } else {
                            return ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _horizontalViewBrands(snapshot),
                            );
                          }
                        }),
                    height: 90,
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Featured products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  FeaturedProducts(),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: new Text(
                              'Sale products',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0),
                            )),
                      ),
                    ],
                  ),
                  SaleProducts(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Recent products',
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                  ),
                  RecentProducts(),
                ],
              ),
            ),
            bottomNavigationBar: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListCategories()));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.category,
                          color: Colors.black,
                        ),
                        Text(
                          "Categories",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListBrands()));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.label,
                          color: Colors.black,
                        ),
                        Text(
                          "Brands",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListProductsFavourite(
                                  email: widget.user.email)));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.favorite,
                          color: Colors.black,
                        ),
                        Text(
                          "Favourite",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10.0,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartPage(
                                    email: widget.user.email,
                                  )));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.black,
                        ),
                        Text(
                          "Cart",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else
          return null;
      },
    );
  }

  void _getSliders() async {
    List<DocumentSnapshot> data = await _slidersServices.getSliders();
    setState(() {
      _sliders = data;
    });
  }

  void _getProducts() async {
    List<DocumentSnapshot> data1 = await _productServices.getProducts();
    setState(() {
      _products = data1;
    });
  }

  List<Image> getImages() {
    List<Image> items = new List();
    _sliders.map((DocumentSnapshot doc) {
      if (doc["isActive"] == true) {
        setState(() {
          items.add(Image.network(doc["sliderImage"]));
        });
      }
    }).toList();
    return items;
  }

  List<DocumentSnapshot> getRecentProducts() {
    List<DocumentSnapshot> items = new List();
    _products.map((DocumentSnapshot doc) {
      if (doc["featured"] == false && doc["onSale"] == false) {
        items.add(doc);
      }
    }).toList();
    return items;
  }

  _horizontalViewCategories(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => Container(
              width: 120,
              child: Card(
                color: Colors.white70,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListProductsInCategory(
                                category: doc["categoryName"])));
                  },
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(doc["categoryImage"]),
                  ),
                ),
              ),
            ))
        .toList();
  }

  _showImageInCarousel() {
    if (_sliders.length > 0) {
      return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: 150,
            child: Carousel(
              images: getImages(),
              animationCurve: Curves.fastOutSlowIn,
              animationDuration: Duration(milliseconds: 1000),
              dotSize: 3,
              indicatorBgPadding: 10,
              dotBgColor: Colors.transparent,
            ),
          ),
        ],
      );
    } else {
      return Text("No products to show");
    }
  }

  _horizontalViewBrands(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => Container(
              width: 135,
              child: Card(
                color: Colors.white70,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ListProductsInBrand(brand: doc["brandName"])));
                  },
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(doc["brandImage"]),
                  ),
                ),
              ),
            ))
        .toList();
  }

  Widget _showInForUser(DocumentSnapshot data) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(
                data["email"],
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              accountName: Text(
                data["username"],
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              currentAccountPicture: GestureDetector(
                  child: data["image"] != null
                      ? Image.network(data["image"])
                      : AvataaarImage(avatar: Avataaar.random())),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyAccount(
                              email: widget.user.email,
                            )));
              },
              child: ListTile(
                title: Text(
                  'My Account',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.account_box,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyOrder(
                              email: widget.user.email,
                            )));
              },
              child: ListTile(
                title: Text(
                  'My Order',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.shopping_basket,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListProductsFavourite(
                              email: widget.user.email,
                            )));
              },
              child: ListTile(
                title: Text(
                  'My Favourites',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.favorite,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartPage(
                              email: widget.user.email,
                            )));
              },
              child: ListTile(
                title: Text(
                  'My Cart',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.shopping_cart,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListCategories()));
              },
              child: ListTile(
                title: Text(
                  'Categories',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.category,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListBrands()));
              },
              child: ListTile(
                title: Text(
                  'Brands',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.label,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
            Divider(
              height: 40.0,
              color: Colors.grey,
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                title: Text(
                  'Settings',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.settings,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: ListTile(
                title: Text(
                  'About',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.help,
                  color: Colors.cyan,
                  size: 30,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                // UserCredential result = await firebaseAuth.signInWithEmail(
                //   email: data["email"],
                // );
                // User user = result.user;
                // FirebaseFirestore.instance
                //     .collection("users")
                //     .doc(data["uid"])
                //     .update({"isLoggedIn": false, "role": "clientt"});
                // signOut();
              },
              child: ListTile(
                title: Text(
                  'Log out',
                  style: TextStyle(fontSize: 18.0),
                ),
                leading: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _showQuantity(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<int> dataCost = new List();
    int temp = 0;
    snapshot.data.docs.forEach((cost) {
      if (cost["userEmail"] == widget.user.email) {
        total = cost["products"]["productQuantity"];
        temp = temp + total;
      }
    });
    dataCost.add(temp);
    return Text(dataCost.last.toString());
  }
}

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 2) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            ),
          )
        ],
      );
    }
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
              ],
            );
          } else {
            final results = snapshot.data.docs.where(
                (DocumentSnapshot a) => a['name'].toString().contains(query));
            return ListView(
                children: results
                    .map<Widget>((a) => Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductDetails(
                                            id: a.data['id'],
                                            name: a.data['name'],
                                            sizes: a.data['sizes'],
                                            colors: a.data['colors'],
                                            price: a.data['price'],
                                            images: a.data['images'],
                                            description: a.data['description'],
                                            brand: a.data['brand'],
                                            category: a.data['category'],
                                            isFavourite: false,
                                          )));
                            },
                            child: ListTile(
                              leading: Image.network(a.data["images"][0]),
                              subtitle: Text(
                                a.data['name'],
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                              ),
                            ),
                          ),
                        ))
                    .toList());
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
              ],
            );
          } else {
            final results = snapshot.data.docs.where(
                (DocumentSnapshot a) => a['name'].toString().contains(query));
            return ListView(
                children: results
                    .map<Widget>((a) => Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0, 0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductDetails(
                                            id: a.data['id'],
                                            name: a.data['name'],
                                            sizes: a.data['sizes'],
                                            colors: a.data['colors'],
                                            price: a.data['price'],
                                            images: a.data['images'],
                                            description: a.data['description'],
                                            brand: a.data['brand'],
                                            category: a.data['category'],
                                            isFavourite: false,
                                          )));
                            },
                            child: ListTile(
                              leading: Image.network(a.data["images"][0]),
                              subtitle: Text(
                                a.data['name'],
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20.0),
                              ),
                            ),
                          ),
                        ))
                    .toList());
          }
        });
  }
}
