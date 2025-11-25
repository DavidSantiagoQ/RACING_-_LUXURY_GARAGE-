import 'package:flutter/material.dart';
import 'EditarCliente.dart';
import '../Modelos/Clientes.dart';

class ClienteDetallePage extends StatefulWidget {
  final Cliente cliente;

  const ClienteDetallePage({super.key, required this.cliente});

  @override
  State<ClienteDetallePage> createState() => _ClienteDetallePageState();
}

class _ClienteDetallePageState extends State<ClienteDetallePage> {
  late Cliente cliente;

  @override
  void initState() {
    super.initState();
    cliente = widget.cliente;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles del Cliente"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal[200],
              child: Text(
                cliente.nombre.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 45),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${cliente.nombre} ${cliente.apellidoPaterno} ${cliente.apellidoMaterno}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            info("Teléfono", cliente.telefono ?? "No registrado", Icons.phone),
            info("Correo", cliente.correo ?? "No registrado", Icons.email),
            info("Dirección", cliente.direccion ?? "No registrada", Icons.home),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Editar"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                final actualizado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarClientePage(cliente: cliente),
                  ),
                );

                if (actualizado is Cliente) {
                  setState(() {
                    cliente = actualizado;
                  });

                  // 🔹 Enviar el cliente actualizado de vuelta a la lista
                  Navigator.pop(context, actualizado);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget info(String titulo, String valor, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(valor),
      ),
    );
  }
}
