import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../Modelos/Clientes.dart';
import '../Servicios/Cliente_Service.dart';
import 'ClienteDetalle.dart';
import 'ClienteVista.dart';
import 'EditarCliente.dart';


class ListaClientesPage extends StatefulWidget {
  const ListaClientesPage({super.key});

  @override
  State<ListaClientesPage> createState() => _ListaClientesPageState();
}

class _ListaClientesPageState extends State<ListaClientesPage> {
  final ClienteService _service = ClienteService();
  List<Cliente> clientes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    try {
      final data = await _service.getClientes();
      setState(() {
        clientes = data;
        cargando = false;
      });
    } catch (e) {
      print("Error cargando clientes: $e");
      setState(() => cargando = false);
    }
  }

  Future<void> eliminarCliente(int id) async {
    bool confirmar = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: "Confirmar",
      text: "¿Desea eliminar este cliente?",
      confirmBtnText: "Sí",
      cancelBtnText: "No",
    );

    if (confirmar) {
      bool ok = await _service.deleteCliente(id);

      if (ok) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Eliminado",
          text: "Cliente eliminado correctamente",
        );
        cargarClientes();
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "No se pudo eliminar",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Clientes Registrados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarClientes,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NuevoClientePage()),
          );

          if (result == true) {
            cargarClientes();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : clientes.isEmpty
          ? const Center(
        child: Text(
          "No hay clientes registrados",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: clientes.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final c = clientes[index];
          return clienteCard(context, c);
        },
      ),
    );
  }

  Widget clienteCard(BuildContext context, Cliente c) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            c.nombre.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        title: Text("${c.nombre} ${c.apellidoPaterno}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(c.correo),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == "editar") {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditarClientePage(cliente: c)),
              );

              if (result is Cliente) {
                setState(() {
                  final index =
                  clientes.indexWhere((e) => e.idCliente == result.idCliente);
                  if (index != -1) clientes[index] = result;
                });
              }
            } else if (value == "eliminar") {
              eliminarCliente(c.idCliente!);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "editar",
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text("Editar"),
                ],
              ),
            ),
            const PopupMenuItem(
              value: "eliminar",
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Eliminar"),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          final actualizado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ClienteDetallePage(cliente: c)),
          );

          // 🔹 Actualizar cliente en la lista si se editó
          if (actualizado is Cliente) {
            setState(() {
              final index =
              clientes.indexWhere((element) => element.idCliente == actualizado.idCliente);
              if (index != -1) clientes[index] = actualizado;
            });
          }
        },
      ),
    );
  }
}
