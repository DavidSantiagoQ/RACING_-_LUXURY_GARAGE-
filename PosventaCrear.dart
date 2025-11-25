import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../Modelos/Posventa.dart';
import '../Servicios/Posventa_Service.dart';

class NuevaPosventaPage extends StatefulWidget {
  final int? idServicio;


  const NuevaPosventaPage({super.key, required this.idServicio});

  @override
  State<NuevaPosventaPage> createState() => _NuevaPosventaPageState();
}

class _NuevaPosventaPageState extends State<NuevaPosventaPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PosventaService();

  // Controladores
  final TextEditingController fechaContacto = TextEditingController();
  final TextEditingController observaciones = TextEditingController();
  final TextEditingController proximaRevision = TextEditingController();
  final TextEditingController tecnicoResponsable = TextEditingController();

  // Enums
  String? medioSeleccionado;
  String? motivoSeleccionado;

  final List<String> mediosContacto = [
    "Teléfono",
    "Correo",
    "WhatsApp",
    "Otro"
  ];

  final List<String> motivosContacto = [
    "Encuesta de satisfacción",
    "Reclamación",
    "Garantía",
    "Recordatorio de mantenimiento",
    "Otro"
  ];

  InputDecoration deco(String label, IconData icon) => InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Registrar Posventa"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fecha contacto
              TextFormField(
                controller: fechaContacto,
                readOnly: true,
                decoration: deco("Fecha de contacto", Icons.calendar_today),
                onTap: () async {
                  DateTime? seleccion = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (seleccion != null) {
                    fechaContacto.text =
                    "${seleccion.year}-${seleccion.month.toString().padLeft(2, '0')}-${seleccion.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 16),

              // Medio contacto
              DropdownButtonFormField<String>(
                decoration:
                deco("Medio de contacto", Icons.phone_android_outlined),
                value: medioSeleccionado,
                items: mediosContacto
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => medioSeleccionado = v),
                validator: (v) =>
                v == null ? "Seleccione un medio de contacto" : null,
              ),
              const SizedBox(height: 16),

              // Motivo contacto
              DropdownButtonFormField<String>(
                decoration:
                deco("Motivo de contacto", Icons.info_outline_rounded),
                value: motivoSeleccionado,
                items: motivosContacto
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => motivoSeleccionado = v),
                validator: (v) =>
                v == null ? "Seleccione un motivo de contacto" : null,
              ),
              const SizedBox(height: 16),

              // Observaciones
              TextFormField(
                controller: observaciones,
                maxLines: 8,
                decoration: deco("Observaciones", Icons.edit_note),
              ),
              const SizedBox(height: 30),

              // Próxima revisión
              TextFormField(
                controller: proximaRevision,
                readOnly: true,
                decoration: deco("Próxima revisión", Icons.event_repeat),
                onTap: () async {
                  DateTime? seleccion = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (seleccion != null) {
                    proximaRevision.text =
                    "${seleccion.year}-${seleccion.month.toString().padLeft(2, '0')}-${seleccion.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 16),

              // Técnico responsable
              TextFormField(
                controller: tecnicoResponsable,
                decoration: deco(
                    "Técnico responsable", Icons.engineering_outlined),
                validator: (v) => v == null || v.isEmpty
                    ? "El técnico responsable es obligatorio"
                    : null,
              ),
              const SizedBox(height: 24),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: guardarPosventa,
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: const Text(
                    "Guardar Posventa",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> guardarPosventa() async {
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Campos incompletos",
        text: "Por favor llena todos los campos obligatorios.",
      );
      return;
    }

    final nueva = Posventa(
      idPosventa: null,
      fechaContacto:
      fechaContacto.text.isEmpty ? null : DateTime.parse(fechaContacto.text),
      medioContacto: medioSeleccionado!,
      motivoContacto: motivoSeleccionado!,
      observaciones: observaciones.text.isEmpty ? null : observaciones.text,
      proximaRevision: proximaRevision.text.isEmpty
          ? null
          : DateTime.parse(proximaRevision.text),
      tecnicoResponsable: tecnicoResponsable.text,
      idServicio: widget.idServicio,
    );

    bool ok = await _service.createPosventa(nueva);

    if (ok) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Posventa Registrada",
        text: "La posventa fue creada correctamente.",
      );
      Navigator.pop(context, true);
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "No se pudo guardar la posventa.",
      );
    }
  }
}
