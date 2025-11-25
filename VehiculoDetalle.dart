import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../Modelos/Vehiculo.dart';
import '../Servicios/Vehiculo_Service.dart';
import 'EditarVehiculo.dart';


class VehiculoDetallePage extends StatelessWidget {
  final Vehiculo vehiculo;

  const VehiculoDetallePage({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Detalles del Vehículo"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Avatar con inicial de la marca
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.teal[300],
            child: Text(
              vehiculo.marca.isNotEmpty
                  ? vehiculo.marca.substring(0, 1).toUpperCase()
                  : "?",
              style: const TextStyle(fontSize: 45, color: Colors.white),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "${vehiculo.marca} ${vehiculo.modelo}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          _tile(Icons.calendar_today, "Año", vehiculo.anio.toString()),
          _tile(Icons.credit_card, "Placas", vehiculo.placas),
          _tile(Icons.confirmation_number, "Número de serie", vehiculo.numeroSerie),
          _tile(Icons.color_lens, "Color", vehiculo.color ?? "No especificado"),
          _tile(Icons.speed, "Kilometraje",
              vehiculo.kilometraje?.toString() ?? "No registrado"),

          const Spacer(),

          // Botones Editar / Eliminar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.teal[600]),
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text("Editar", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditarVehiculoPage(vehiculo: vehiculo),
                    ),
                  ).then((value) {
                    if (value == true) Navigator.pop(context, true);
                  });
                },
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.delete, color: Colors.black),
                label: const Text("Eliminar", style: TextStyle(color: Colors.black)),
                onPressed: () => _eliminar(context),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  void _eliminar(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "¿Eliminar?",
      text: "Esta acción no se puede deshacer.",
      confirmBtnText: "Eliminar",
      cancelBtnText: "Cancelar",
      onConfirmBtnTap: () async {
        Navigator.pop(context); // Cierra la confirmación

        bool ok = await VehiculoService().deleteVehiculo(vehiculo.idVehiculo!);

        if (ok) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: "Vehículo eliminado",
          ).then((_) {
            Navigator.pop(context, true);
          });
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            text: "No se pudo eliminar",
          );
        }
      },
    );
  }
}
