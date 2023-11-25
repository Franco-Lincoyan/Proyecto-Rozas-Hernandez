import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajomoviles/pages2/Eventos_agregar.dart';
import 'package:trabajomoviles/services/auth_service.dart';

class MostrarPage extends StatefulWidget {
  @override
  State createState() => _MostrarPageState();
}

class _MostrarPageState extends State<MostrarPage> {
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

                      return Card(
                        elevation: esProximo ? 8.0 : 4.0,
                        margin: EdgeInsets.all(8.0),
                        color: esProximo ? Colors.yellow : null,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(eventData['nombre']),
                              subtitle: Text('Fecha: ${fecha.toLocal()}'),
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
                                              color: Colors.white)),
                                      Text('Hora: ${eventData['hora']}',
                                          style: TextStyle(
                                              color: Colors.white)),
                                      Text(
                                          'Descripción: ${eventData['descripcion']}',
                                          style: TextStyle(
                                              color: Colors.white)),
                                      Text(
                                          'Tipo: ${eventData['tipo_evento']}',
                                          style: TextStyle(
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.favorite),
                                  color: Colors.red,
                                  onPressed: () {
                                    _authService.incrementarLikes(
                                        eventDoc.id);
                                  },
                                ),
                                Text('Likes: ${eventData['likes']}'),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _borrarEvento(
                                        context, eventDoc.id);
                                  },
                                ),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return AgregarPage();
            }),
          );
        },
        child: Icon(Icons.add),
      ),
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

  void _borrarEvento(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar borrado'),
          content:
              Text('¿Estás seguro de que quieres borrar este evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _authService.eventoBorrar(eventId);
                Navigator.of(context).pop();
              },
              child: Text('Borrar'),
            ),
          ],
        );
      },
    );
  }
}
