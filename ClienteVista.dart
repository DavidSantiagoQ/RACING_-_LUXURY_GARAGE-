import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../Modelos/Clientes.dart';
import '../Servicios/Cliente_Service.dart';

class NuevoClientePage extends StatefulWidget {
  const NuevoClientePage({super.key});

  @override
  State<NuevoClientePage> createState() => _NuevoClientePageState();
}

class _NuevoClientePageState extends State<NuevoClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ClienteService();

  // Controladores
  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellidoP = TextEditingController();
  final TextEditingController apellidoM = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController direccion = TextEditingController();

  // --- Decoración igual a EditarClientePage ---
  InputDecoration deco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.teal),
        borderRadius: BorderRadius.circular(14),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Registrar Cliente"),
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
                onPressed: _guardarCliente,
                icon: const Icon(Icons.save, color: Colors.black),
                label: const Text("Guardar Cliente", style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reutilizamos mismo estilo del EditarClientePage
  Widget campo(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        decoration: deco(label, icon),
        validator: (value) =>
        value == null || value.trim().isEmpty ? "Este campo es obligatorio" : null,
      ),
    );
  }

  // Tu misma lógica, NO se tocó
  Future<void> _guardarCliente() async {
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Campos incompletos",
        text: "Por favor complete todos los campos.",
      );
      return;
    }

    final nuevoCliente = Cliente(
      idCliente: 0,
      nombre: nombre.text.trim(),
      apellidoPaterno: apellidoP.text.trim(),
      apellidoMaterno: apellidoM.text.trim(),
      telefono: telefono.text.trim(),
      correo: correo.text.trim(),
      direccion: direccion.text.trim(),
    );

    try {
      bool exito = await _service.createCliente(nuevoCliente);

      if (!mounted) return;

      if (exito) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Éxito",
          text: "Cliente registrado correctamente",
        );

        Navigator.pop(context, true);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "No se pudo registrar el cliente.",
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error inesperado",
        text: "Ocurrió un error: $e",
      );
    }
  }
}
