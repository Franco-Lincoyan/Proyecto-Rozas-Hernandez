
import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreServices{
Stream<QuerySnapshot> evento(){

  return FirebaseFirestore.instance.collection("evento").orderBy("fecha").snapshots();

}


}