import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoradoCard extends StatefulWidget {
  final String nombre;
  final DateTime fecha;
  final String lugar;
  final String descripcion;
  final int likes;
  final String tipo;
  final String? foto;
  final Timestamp? hora;

  MoradoCard({
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.descripcion,
    required this.likes,
    required this.foto,
    required this.tipo,
    required this.hora,
  });

  @override
  _MoradoCardState createState() => _MoradoCardState();
}

class _MoradoCardState extends State<MoradoCard> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 96, 63, 215),
      elevation: 5,
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.foto != null)
            Image.network(
              widget.foto!,
              fit: BoxFit.cover,
              height: 200,
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nombre,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  widget.fecha.toLocal().toString(),
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  widget.lugar,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  widget.hora != null ? widget.hora!.toDate().toString() : '',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  widget.tipo,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 8),
                if (showDetails)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.descripcion,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        showDetails ? Icons.remove : Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          showDetails = !showDetails;
                        });
                      },
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            // Acción al hacer clic en Me Gusta
                          },
                        ),
                        Text(
                          '${widget.likes}',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
