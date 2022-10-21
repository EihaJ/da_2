import 'package:cloud_firestore/cloud_firestore.dart';

class ProductServices {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String ref = "products";

  Future<List<DocumentSnapshot>> getProducts() =>
      _fireStore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });
}
