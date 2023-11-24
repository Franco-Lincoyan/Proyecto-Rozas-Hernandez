import 'package:flutter/material.dart';
import 'package:trabajomoviles/pages/Entre.dart';
import 'package:trabajomoviles/services/auth_service.dart';

class Home_page extends StatefulWidget {
  const Home_page({Key? key}) : super(key: key);

  @override
  State<Home_page> createState() => _Home_pageState();
}

class _Home_pageState extends State<Home_page> {
  final AuthService _authService = AuthService();
  final TextEditingController usuarioCtrl = TextEditingController();
  final TextEditingController claveCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'EVENTO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black,
                offset: Offset(3.0, 3.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/FondoSignIn.jpg', fit: BoxFit.cover),
          Positioned(
            top: 570,
            left: 125,
            child: ElevatedButton(
              onPressed: () async {
              String usuario = usuarioCtrl.text;
              String clave = claveCtrl.text;
              if (usuario.isNotEmpty && clave.isNotEmpty) {
                var result = await _authService.signInWithEmailAndPassword(usuario, clave);
                if (result != null) {
                  print('Inicio de sesión exitoso: ${result.email}');
                } else {
                  print('Error en el inicio de sesión con correo y contraseña');
                }
              } else {
                print('Usuario y clave son obligatorios');
              }
            },
            child: Text('Iniciar sesión'),
          ),
          ),
          Positioned(
            top: 690,
            left: 110,
            child: ElevatedButton(
              onPressed: () {
                print('Inicio la sesion');
              },
              child: Text('Ingresar sin cuenta'),
            ),
          ),
          Positioned(
            top: 630,
            left: 150,
            child: ElevatedButton(
            onPressed: () async {
            var result = await _authService.signInWithGoogle();
            if (result != null) {
              print('Inicio de sesión exitoso con Google: ${result.displayName}');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return Entre_Page();}),
              );
            } else {
              print('Error en el inicio de sesión con Google');
            }
          },
            style: ElevatedButton.styleFrom(
              primary: Colors.transparent,
              elevation: 0,
            ),
            child: Image.asset(
              'assets/images/google.png',
              height: 40.0,
            ),
          ),
          ),
          Positioned(
            top: 350,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8.0,
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usuarioCtrl,
                      decoration: InputDecoration(labelText: 'Usuario'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 460,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8.0,
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: claveCtrl,
                      decoration: InputDecoration(labelText: 'Clave'),keyboardType: TextInputType.visiblePassword,obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}