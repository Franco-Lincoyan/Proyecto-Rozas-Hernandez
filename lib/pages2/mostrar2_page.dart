import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:trabajomoviles/services/auth_service.dart';

class MostrarPage2 extends StatefulWidget {
  @override
  State createState() => _MostrarPage2State();
}

class _MostrarPage2State extends State<MostrarPage2> {
  final AuthService _authService = AuthService();
  String _filtro = "Futuros"; // Valor predeterminado

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime proximosTresDias = now.add(Duration(days: 3));

    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: Column(
        children: [
          _buildFiltroDropdown(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getEventosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No hay eventos disponibles'),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((eventDoc) {
                    Map<String, dynamic>? eventData =
                        eventDoc.data() as Map<String, dynamic>?;

                    if (eventData != null && eventData['fecha'] != null) {
                      Timestamp fechaTimestamp =
                          eventData['fecha'] as Timestamp;
                      DateTime fecha = fechaTimestamp.toDate();

                      // Verificar si el evento está próximo a realizarse
                      bool esProximo =
                          fecha.isAfter(now) && fecha.isBefore(proximosTresDias);

                      int likes = eventData['likes'] ?? 0;

                      return Card(
                        elevation: esProximo ? 8.0 : 4.0,
                        margin: EdgeInsets.all(8.0),
                        color: esProximo ? Colors.yellow : null,
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(eventData['nombre']),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.favorite),
                                        color: Colors.red,
                                        onPressed: () {
                                          _authService.incrementarLikes(eventDoc.id);
                                          // También puedes actualizar localmente el contador de likes
                                          setState(() {
                                            likes++;
                                          });
                                        },
                                      ),
                                      Text('Likes: $likes'),
                                    ],
                                  ),
                                ],
                              ),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(eventData['foto']),
                              ),
                            ),
                            ExpansionTile(
                              title: Text('Detalles'),
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(eventData['foto']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Lugar: ${eventData['lugar']}',
                                          style: TextStyle(
                                              color: Colors.white,fontWeight: FontWeight.bold)),
                                      Text('Fecha: ${fecha.toLocal()}',
                                          style: TextStyle(
                                              color: Colors.white,fontWeight: FontWeight.bold)),
                                      Text('Hora: ${eventData['hora']}',
                                          style: TextStyle(
                                              color: Colors.white,fontWeight: FontWeight.bold)),
                                      Text(
                                          'Descripción: ${eventData['descripcion']}',
                                          style: TextStyle(
                                              color: Colors.white,fontWeight: FontWeight.bold)),
                                      Text(
                                          'Tipo: ${eventData['tipo_evento']}',
                                          style: TextStyle(
                                              color: Colors.white,fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Row eliminado para botones de eliminar y agregar
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      // FloatingActionButton eliminado
    );
  }

  Widget _buildFiltroDropdown() {
    return DropdownButton<String>(
      value: _filtro,
      onChanged: (String? newValue) {
        setState(() {
          _filtro = newValue!;
        });
      },
      items: ["Futuros", "Pasados"]
          .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ),
          )
          .toList(),
    );
  }

  Stream<QuerySnapshot> _getEventosStream() {
    if (_filtro == "Futuros") {
      return FirebaseFirestore.instance
          .collection("evento")
          .where('fecha', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection("evento")
          .where('fecha', isLessThan: DateTime.now())
          .snapshots();
    }
  }
}
