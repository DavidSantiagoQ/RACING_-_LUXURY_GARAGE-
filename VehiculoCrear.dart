import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../Modelos/Vehiculo.dart';
import '../Modelos/Clientes.dart';
import '../Servicios/Vehiculo_Service.dart';
import '../Servicios/Cliente_Service.dart';

class NuevoVehiculoPage extends StatefulWidget {
  const NuevoVehiculoPage({super.key});

  @override
  State<NuevoVehiculoPage> createState() => _NuevoVehiculoPageState();
}

class _NuevoVehiculoPageState extends State<NuevoVehiculoPage> {
  final _formKey = GlobalKey<FormState>();
  final _vehiculoService = VehiculoService();
  final _clienteService = ClienteService();

  List<Cliente> clientes = [];
  Cliente? clienteSeleccionado;

  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController placasController = TextEditingController();
  final TextEditingController numeroSerieController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController kilometrajeController = TextEditingController();

  bool cargandoClientes = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarClientes();
  }

  Future<void> cargarClientes() async {
    try {
      final data = await _clienteService.getClientes();
      setState(() {
        clientes = data;
        if (clientes.isNotEmpty) clienteSeleccionado = clientes[0];
        cargandoClientes = false;
      });
    } catch (e) {
      print("Error cargando clientes: $e");
      setState(() => cargandoClientes = false);
    }
  }

  InputDecoration deco(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        title: const Text("Registrar Vehículo"),
      ),
      body: cargandoClientes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Dropdown de clientes
              DropdownButtonFormField<Cliente>(
                value: clienteSeleccionado,
                decoration: deco("Seleccionar Cliente", Icons.person_outline),
                items: clientes
                    .map((c) =>
                    DropdownMenuItem(
                      value: c,
                      child: Text("${c.nombre} ${c.apellidoPaterno}"),
                    ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    clienteSeleccionado = v;
                  });
                },
                validator: (v) =>
                v == null ? "Debe seleccionar un cliente" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: marcaController,
                decoration: deco("Marca", Icons.directions_car),
                validator: (v) =>
                v == null || v.isEmpty ? "La marca es obligatoria" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: modeloController,
                decoration: deco("Modelo", Icons.car_repair),
                validator: (v) =>
                v == null || v.isEmpty ? "El modelo es obligatorio" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: anioController,
                decoration: deco("Año", Icons.calendar_today),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "El año es obligatorio";
                  if (int.tryParse(v) == null)
                    return "Debe ser un número válido";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: placasController,
                decoration: deco("Placas", Icons.credit_card),
                validator: (v) =>
                v == null || v.isEmpty ? "Las placas son obligatorias" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: numeroSerieController,
                decoration: deco("Número de Serie", Icons.confirmation_number),
                validator: (v) =>
                v == null || v.isEmpty
                    ? "El número de serie es obligatorio"
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: colorController,
                decoration: deco("Color", Icons.color_lens),
                validator: (v) =>
                v == null || v.isEmpty
                    ? "El color es obligatorio"
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: kilometrajeController,
                decoration: deco("Kilometraje", Icons.speed),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty
                    ? "El kilometraje es obligatorio"
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: guardarVehiculo, // tu función para guardar
                icon: const Icon(Icons.save, color: Colors.black),
                label: const Text(
                  "Registrar Vehículo",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void guardarVehiculo() async {
    // Validación del formulario
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: "Campos incompletos",
        text: "Debes llenar todos los campos obligatorios.",
      );
      return;
    }

    setState(() => guardando = true);

    // Crear objeto Vehiculo con los datos del formulario
    final vehiculo = Vehiculo(
      marca: marcaController.text.trim(),
      modelo: modeloController.text.trim(),
      anio: int.parse(anioController.text.trim()),
      placas: placasController.text.trim(),
      numeroSerie: numeroSerieController.text.trim(),
      color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
      kilometraje: kilometrajeController.text.trim().isEmpty
          ? null
          : int.parse(kilometrajeController.text.trim()),
      idCliente: clienteSeleccionado!.idCliente!,
    );

    // Guardar en el backend
    bool ok = await _vehiculoService.createVehiculo(vehiculo);

    setState(() => guardando = false);

    if (ok) {
      // Alerta de éxito y espera a que el usuario confirme
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: "Vehículo Registrado",
        text: "El vehículo fue agregado correctamente.",
        barrierDismissible: false,
      );

      // Regresa a la lista de vehículos y refresca
      Navigator.pop(context, true);
    } else {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "No se pudo registrar el vehículo.",
      );
    }
  }
}