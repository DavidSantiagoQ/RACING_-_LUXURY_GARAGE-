import 'package:flutter/material.dart';
import 'package:taller_racing_luxury/Modelos/Vehiculo.dart';
import 'package:taller_racing_luxury/Servicios/Vehiculo_Service.dart';
import 'package:taller_racing_luxury/Vistas/VehiculoCrear.dart';

import 'VehiculoDetalle.dart';


class ListadoVehiculosPage extends StatefulWidget {
  const ListadoVehiculosPage({super.key});

  @override
  State<ListadoVehiculosPage> createState() => _ListadoVehiculosPageState();
}

class _ListadoVehiculosPageState extends State<ListadoVehiculosPage> {
  final VehiculoService _service = VehiculoService();
  List<Vehiculo> vehiculos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarVehiculos();
  }

  void cargarVehiculos() async {
    setState(() => loading = true);
    try {
      final data = await _service.getVehiculos();
      setState(() {
        vehiculos = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error al cargar vehículos")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Vehículos Registrados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarVehiculos,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NuevoVehiculoPage()),
          );

          if (result == true) {
            cargarVehiculos();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : vehiculos.isEmpty
          ? const Center(child: Text("No hay vehículos registrados"))
          : ListView.builder(
        itemCount: vehiculos.length,
        itemBuilder: (context, index) {
          final v = vehiculos[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[300],
                child: Text(
                  v.marca.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white),
                ),
              ),
              title: Text("${v.marca} ${v.modelo}"),
              subtitle: Text("Placas: ${v.placas}"),
              trailing:
              const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          VehiculoDetallePage(vehiculo: v)),
                );
                if (updated == true) cargarVehiculos();
              },
            ),
          );
        },
      ),
    );
  }
}
