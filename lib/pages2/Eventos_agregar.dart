import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trabajomoviles/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class AgregarPage extends StatefulWidget {
  const AgregarPage({Key? key}) : super(key: key);

  @override
  State<AgregarPage> createState() => _AgregarPageState();
}

class _AgregarPageState extends State<AgregarPage> {
  TextEditingController nombreController = TextEditingController();
  DateTime? fechaSeleccionada;
  TimeOfDay? horaSeleccionada;
  TextEditingController lugarController = TextEditingController();
  TextEditingController fotografiaController = TextEditingController();
  String tipoSeleccionado = "Cultural";
  TextEditingController descripcionController = TextEditingController();
  TextEditingController likesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _seleccionarFecha(context),
                    child: Text('Seleccionar Fecha'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _seleccionarHora(context),
                    child: Text('Seleccionar Hora'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: lugarController,
              decoration: InputDecoration(labelText: 'Lugar'),
            ),
            ElevatedButton(
              onPressed: _seleccionarFoto,
              child: Text('Seleccionar Foto'),
            ),
            DropdownButton<String>(
              value: tipoSeleccionado,
              onChanged: (String? newValue) {
                setState(() {
                  tipoSeleccionado = newValue!;
                });
              },
              items: <String>['Cultural', 'Deportivo', 'Social', 'Otros']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              hint: Text('Seleccionar Tipo'),
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: likesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Likes'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                agregarEvento();
              },
              child: Text('Agregar Evento'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        horaSeleccionada = hora;
      });
    }
  }

  Future<void> _seleccionarFoto() async {
    TextEditingController urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar Foto'),
          content: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    Navigator.of(context).pop(pickedFile.path);
                  }
                },
                child: Text('Seleccionar desde Galería'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'URL de la Foto'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(urlController.text);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    ).then((selectedPath) {
      if (selectedPath != null && selectedPath.isNotEmpty) {
        setState(() {
          fotografiaController.text = selectedPath;
        });
      }
    });
  }

  void agregarEvento() async {
    if (fechaSeleccionada != null && horaSeleccionada != null) {
      DateTime fechaHora = DateTime(
        fechaSeleccionada!.year,
        fechaSeleccionada!.month,
        fechaSeleccionada!.day,
        horaSeleccionada!.hour,
        horaSeleccionada!.minute,
      );

      String fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaHora);
      String horaFormateada = DateFormat('HH:mm:ss').format(fechaHora);

      String nombre = nombreController.text;
      String lugar = lugarController.text;
      String fotografia = fotografiaController.text;
      String tipo = tipoSeleccionado;
      String descripcion = descripcionController.text;
      int likes = int.tryParse(likesController.text) ?? 0;

      await AuthService().eventoAgregar(
        0,
        nombre,
        fechaHora,
        lugar,
        Timestamp.fromDate(fechaHora),
        descripcion,
        tipo,
        likes,
        fotografia,
      );

      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Selecciona una fecha y una hora'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
