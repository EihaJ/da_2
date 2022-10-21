import 'package:cloud_firestore/cloud_firestore.dart';

class CartsServices {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String ref = "carts";

  Future<List<DocumentSnapshot>> getCarts() =>
      _fireStore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });
}
