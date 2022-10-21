import 'package:cloud_firestore/cloud_firestore.dart';

class BrandServices {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String ref = "brands";

  Future<List<DocumentSnapshot>> getBrands() =>
      _fireStore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });
}
