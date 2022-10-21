import 'package:cloud_firestore/cloud_firestore.dart';

class SlidersServices {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  String ref = "sliders";

  Future<List<DocumentSnapshot>> getSliders() =>
      _fireStore.collection(ref).get().then((snaps) {
        return snaps.docs;
      });
}
