import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../Modelos/Clientes.dart';
import '../Servicios/Cliente_Service.dart';

class EditarClientePage extends StatefulWidget {
  final Cliente cliente;

  const EditarClientePage({super.key, required this.cliente});

  @override
  State<EditarClientePage> createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();

  late TextEditingController nombre;
  late TextEditingController apellidoP;
  late TextEditingController apellidoM;
  late TextEditingController telefono;
  late TextEditingController correo;
  late TextEditingController direccion;

  @override
  void initState() {
    super.initState();
    nombre = TextEditingController(text: widget.cliente.nombre);
    apellidoP = TextEditingController(text: widget.cliente.apellidoPaterno);
    apellidoM = TextEditingController(text: widget.cliente.apellidoMaterno);
    telefono = TextEditingController(text: widget.cliente.telefono);
    correo = TextEditingController(text: widget.cliente.correo);
    direccion = TextEditingController(text: widget.cliente.direccion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              campo(nombre, "Nombre", Icons.person),
              campo(apellidoP, "Apellido paterno", Icons.badge),
              campo(apellidoM, "Apellido materno", Icons.badge_outlined),
              campo(telefono, "Teléfono", Icons.phone),
              campo(correo, "Correo", Icons.email),
              campo(direccion, "Dirección", Icons.home),

              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: actualizarCliente,
                icon: const Icon(Icons.save),
                label: const Text("Guardar Cambios"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campo(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        validator: (value) =>
        value == null || value.trim().isEmpty ? "Campo obligatorio" : null,
      ),
    );
  }

  Future<void> actualizarCliente() async {
    if (!_formKey.currentState!.validate()) return;

    final cli = Cliente(
      idCliente: widget.cliente.idCliente,
      nombre: nombre.text.trim(),
      apellidoPaterno: apellidoP.text.trim(),
      apellidoMaterno: apellidoM.text.trim(),
      telefono: telefono.text.trim(),
      correo: correo.text.trim(),
      direccion: direccion.text.trim(),
    );

    bool ok = await _service.updateCliente(cli.idCliente!, cli);
    if (!mounted) return;

    if (ok) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Actualizado",
        text: "Cliente actualizado correctamente",
        onConfirmBtnTap: () {
          Navigator.pop(context); // cierra alerta
          Navigator.pop(context, cli); // Regresa cliente actualizado
        },
      );
    }
  }
}
