import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../Modelos/Vehiculo.dart';
import '../Servicios/Vehiculo_Service.dart';

class EditarVehiculoPage extends StatefulWidget {
  final Vehiculo vehiculo;

  const EditarVehiculoPage({super.key, required this.vehiculo});

  @override
  State<EditarVehiculoPage> createState() => _EditarVehiculoPageState();
}

class _EditarVehiculoPageState extends State<EditarVehiculoPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = VehiculoService();

  late TextEditingController marca;
  late TextEditingController modelo;
  late TextEditingController anio;
  late TextEditingController placas;
  late TextEditingController numeroSerie;
  late TextEditingController color;
  late TextEditingController kilometraje;

  @override
  void initState() {
    super.initState();
    marca = TextEditingController(text: widget.vehiculo.marca);
    modelo = TextEditingController(text: widget.vehiculo.modelo);
    anio = TextEditingController(text: widget.vehiculo.anio.toString());
    placas = TextEditingController(text: widget.vehiculo.placas);
    numeroSerie = TextEditingController(text: widget.vehiculo.numeroSerie);
    color = TextEditingController(text: widget.vehiculo.color ?? '');
    kilometraje = TextEditingController(
      text: widget.vehiculo.kilometraje?.toString() ?? "",
    );
  }

  InputDecoration deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Editar Vehículo"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _campoTexto(marca, "Marca", Icons.car_rental),
            const SizedBox(height: 16),
            _campoTexto(modelo, "Modelo", Icons.car_repair),
            const SizedBox(height: 16),
            _campoNumero(anio, "Año", Icons.calendar_month),
            const SizedBox(height: 16),
            _campoTexto(placas, "Placas", Icons.credit_card),
            const SizedBox(height: 16),
            _campoTexto(numeroSerie, "Número de Serie", Icons.confirmation_number),
            const SizedBox(height: 16),
            _campoTexto(color, "Color", Icons.color_lens),
            const SizedBox(height: 16),
            _campoNumero(kilometraje, "Kilometraje", Icons.speed),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
              ),
              onPressed: _actualizarVehiculo,
              child: const Text(
                "Guardar Cambios",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: deco(label, icon),
      validator: (v) => v == null || v.isEmpty ? "$label es obligatorio" : null,
    );
  }

  Widget _campoNumero(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: deco(label, icon),
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.isEmpty) return "$label es obligatorio";
        if (int.tryParse(v) == null) return "Debe ser un número válido";
        return null;
      },
    );
  }

  void _actualizarVehiculo() async {
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Campos incompletos",
        text: "Por favor, complete todos los campos obligatorios correctamente.",
      );
      return;
    }

    final v = Vehiculo(
      idVehiculo: widget.vehiculo.idVehiculo,
      marca: marca.text.trim(),
      modelo: modelo.text.trim(),
      anio: int.parse(anio.text.trim()),
      placas: placas.text.trim(),
      numeroSerie: numeroSerie.text.trim(),
      color: color.text.trim(),
      kilometraje: int.parse(kilometraje.text.trim()),
      idCliente: widget.vehiculo.idCliente,
    );

    bool ok = await _service.updateVehiculo(v.idVehiculo!, v);

    if (ok) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Actualizado",
        text: "Vehículo actualizado correctamente",
      );
      Navigator.pop(context, true); // Retorna true para refrescar la lista
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Hubo un problema al actualizar",
      );
    }
  }
}
