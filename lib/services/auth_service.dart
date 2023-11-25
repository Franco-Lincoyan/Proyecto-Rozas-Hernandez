import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get usuario {
    return _firebaseAuth.authStateChanges();
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (error) {
      print('Error al iniciar sesión con correo y contraseña: $error');
      return null;
    }
  }


Future<User?> signInWithGoogle() async {
  
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user;
  } catch (error) {
    print('Error al iniciar sesión con Google: $error');
    return null;
  }
}
//AGREGAR
Future<void> eventoAgregar(int id, String nombre, DateTime fecha, String lugar, Timestamp hora, String descripcion, String tipo, int likes, String foto) async {

  return FirebaseFirestore.instance.collection("evento").doc().set({
    "nombre": nombre,
    "fecha": Timestamp.fromDate(fecha),  // Convertir DateTime a Timestamp
    "lugar": lugar,
    "hora": hora,
    "descripcion": descripcion,
    "tipo_evento": tipo,  // Corregir el nombre del campo
    "likes": likes,
    "foto": foto
  });
}


//MOSTRAR

Future<QuerySnapshot> mostrar() async {
  return FirebaseFirestore.instance.collection("evento").get();
}

//BORRAR
Future<void> eventoBorrar(String id) async{
return FirebaseFirestore.instance.collection("evento").doc(id).delete();

}


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> incrementarLikes(String eventId) async {
    await _firestore.collection("evento").doc(eventId).update({
      'likes': FieldValue.increment(1),
    });
  }
}






  




