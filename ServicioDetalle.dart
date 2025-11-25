import 'package:flutter/material.dart';
import 'package:taller_racing_luxury/Modelos/Servicio.dart';

import 'EditarServicio.dart';
import 'PosventaCrear.dart';

class ServicioDetallePage extends StatefulWidget {
  final Servicio servicio;

  const ServicioDetallePage({super.key, required this.servicio});

  @override
  State<ServicioDetallePage> createState() => _ServicioDetallePageState();
}

class _ServicioDetallePageState extends State<ServicioDetallePage> {
  late Servicio servicio;

  @override
  void initState() {
    super.initState();
    servicio = widget.servicio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle del Servicio"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔹 Icono principal
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal[200],
              child: const Icon(
                Icons.car_repair,
                size: 55,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Título
            Text(
              servicio.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // 🔹 TARJETAS DE INFO
            info("Tipo", servicio.tipo, Icons.tune),
            info("Estado", servicio.estado, Icons.info),
            info(
              "Cliente",
              servicio.cliente?.nombre ?? "No asignado",
              Icons.person,
            ),
            info(
              "Vehículo",
              servicio.vehiculo != null
                  ? "${servicio.vehiculo!.marca} ${servicio.vehiculo!.modelo}"
                  : "No asignado",
              Icons.directions_car,
            ),
            info(
              "Fecha de entrada",
              servicio.fechaEntrada ?? "No registrada",
              Icons.calendar_month,
            ),
            info(
              "Fecha de salida",
              servicio.fechaSalida ?? "No registrada",
              Icons.date_range,
            ),

            const SizedBox(height: 30),

            // -------------------------------------------------------------
            // 🔥 BOTÓN EDITAR (LARGO, ABAJO)
            // -------------------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Editar Servicio",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final actualizado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditarServicioPage(servicio: servicio),
                    ),
                  );

                  if (actualizado is Servicio) {
                    setState(() {
                      servicio = actualizado;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 15),

            // -------------------------------------------------------------
            // 🔥 BOTÓN POSVENTA (SOLO SI FINALIZADO)
            // -------------------------------------------------------------
            if (servicio.estado.toLowerCase() == "finalizado")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.build_circle),
                  label: const Text(
                    "Registrar Posventa",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NuevaPosventaPage(idServicio: servicio.idServicio),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 🔹 Función reutilizable para tarjetas
  Widget info(String titulo, String valor, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(valor),
      ),
    );
  }
}
