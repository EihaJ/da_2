import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryServices {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String ref = "Categories";

  Future<List<DocumentSnapshot>> getCategories() =>
      _fireStore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });
}
