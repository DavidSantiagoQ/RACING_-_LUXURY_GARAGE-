import 'package:flutter/material.dart';
import 'package:taller_racing_luxury/Modelos/Servicio.dart';
import 'package:taller_racing_luxury/Servicios/Servicio_Service.dart';
import 'package:taller_racing_luxury/Vistas/ServicioCrear.dart';

import 'ServicioDetalle.dart';


class ListadoServiciosPage extends StatefulWidget {
  const ListadoServiciosPage({super.key});

  @override
  State<ListadoServiciosPage> createState() => _ListadoServiciosPageState();
}

class _ListadoServiciosPageState extends State<ListadoServiciosPage> {
  final ServicioService _service = ServicioService();
  List<Servicio> servicios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarServicios();
  }

  void cargarServicios() async {
    setState(() => loading = true);
    try {
      final data = await _service.getServicios();
      setState(() {
        servicios = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error al cargar servicios")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Servicios Registrados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarServicios,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NuevoServicioPage()),
          );

          if (result == true) cargarServicios();
        },
        child: const Icon(Icons.add),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : servicios.isEmpty
          ? const Center(child: Text("No hay servicios registrados"))
          : ListView.builder(
        itemCount: servicios.length,
        itemBuilder: (context, index) {
          final s = servicios[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[300],
                child: Text(
                  s.nombre.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white),
                ),
              ),
              title: Text(s.nombre),
              subtitle: Text(
                "Tipo: ${s.tipo}\n"
                    "Estado: ${s.estado}\n"
                    "Cliente: ${s.cliente?.nombre ?? 'Sin asignar'}\n"
                    "Vehículo: ${s.vehiculo != null ? s.vehiculo!.marca + ' ' + s.vehiculo!.modelo : 'Sin asignar'}",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServicioDetallePage(servicio: s),
                  ),
                );

                if (updated == true) cargarServicios();
              },
            ),
          );
        },
      ),
    );
  }
}
