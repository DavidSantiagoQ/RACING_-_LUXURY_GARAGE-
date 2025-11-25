import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart';

import '../Modelos/Servicio.dart';
import '../Modelos/Clientes.dart';
import '../Modelos/Vehiculo.dart';

import '../Servicios/Cliente_Service.dart';
import '../Servicios/Servicio_Service.dart';
import '../Servicios/Vehiculo_Service.dart';

class NuevoServicioPage extends StatefulWidget {
  final Servicio? servicio;

  const NuevoServicioPage({super.key, this.servicio});

  @override
  State<NuevoServicioPage> createState() => _NuevoServicioPageState();
}

class _NuevoServicioPageState extends State<NuevoServicioPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController fechaEntradaCtrl = TextEditingController();
  final TextEditingController fechaSalidaCtrl = TextEditingController();
  final TextEditingController duracionCtrl = TextEditingController();
  final TextEditingController costoCtrl = TextEditingController();

  // Listas y selección
  List<Cliente> clientes = [];
  List<Vehiculo> vehiculos = [];
  Cliente? clienteSeleccionado;
  Vehiculo? vehiculoSeleccionado;

  String? nombreSeleccionado;
  String? tipoSeleccionado;
  String? estadoSeleccionado;

  bool isLoading = true;

  // Listas fijas
  final List<String> nombresServicios = [
    "Cambio de aceite",
    "Mantenimiento general",
    "Alineación y balanceo",
    "Frenos",
    "Scanner / diagnóstico",
    "Servicio mayor",
    "Afinación",
  ];

  final List<String> tiposServicios = [
    "Preventivo",
    "Correctivo",
    "Electrico",
    "Carroceria",
    "Diagnostico",
  ];

  final List<String> estados = [
    "Pendiente",
    "En Proceso",
    "Finalizado",
    "Facturado",
    "Cancelado",
  ];

  @override
  void initState() {
    super.initState();
    cargarDatos();

    if (widget.servicio != null) {
      fechaEntradaCtrl.text = widget.servicio!.fechaEntrada ?? "";
      fechaSalidaCtrl.text = widget.servicio!.fechaSalida ?? "";
      duracionCtrl.text = widget.servicio!.duracionEstimada ?? "";
      costoCtrl.text = widget.servicio!.costoTotal?.toString() ?? "";

      nombreSeleccionado = widget.servicio!.nombre;
      tipoSeleccionado = widget.servicio!.tipo;
      estadoSeleccionado = widget.servicio!.estado;
    }
  }

  Future<void> cargarDatos() async {
    setState(() => isLoading = true);

    clientes = await ClienteService().getClientes();
    vehiculos = await VehiculoService().getVehiculos();

    // Si es edición, seleccionar cliente y vehículo existentes
    if (widget.servicio != null) {
      clienteSeleccionado = clientes.firstWhere(
              (c) => c.idCliente == widget.servicio!.idCliente,
          orElse: () => clientes.first);

      vehiculoSeleccionado = vehiculos.firstWhere(
              (v) => v.idVehiculo == widget.servicio!.idVehiculo,
          orElse: () => vehiculos.first);
    }

    setState(() => isLoading = false);
  }

  InputDecoration deco(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
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

  Future<void> seleccionarFecha(TextEditingController controller) async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      controller.text = DateFormat("yyyy-MM-dd").format(fecha);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicio == null
            ? "Nuevo Servicio"
            : "Editar Servicio"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              campoFecha("Fecha de entrada", fechaEntradaCtrl),
              const SizedBox(height: 16),
              campoFecha("Fecha de salida", fechaSalidaCtrl),
              const SizedBox(height: 16),
              campoDropdown<String>(
                "Nombre del servicio",
                nombresServicios,
                nombreSeleccionado,
                    (v) => setState(() => nombreSeleccionado = v),
              ),
              const SizedBox(height: 16),
              campoDropdown<String>(
                "Tipo de servicio",
                tiposServicios,
                tipoSeleccionado,
                    (v) => setState(() => tipoSeleccionado = v),
              ),
              const SizedBox(height: 16),
              campoTexto("Duración estimada", duracionCtrl, Icons.schedule),
              const SizedBox(height: 16),
              campoTexto("Costo total", costoCtrl, Icons.attach_money,
                  teclado: TextInputType.number),
              const SizedBox(height: 16),
              campoDropdown<String>(
                "Estado",
                estados,
                estadoSeleccionado,
                    (v) => setState(() => estadoSeleccionado = v),
              ),
              const SizedBox(height: 16),
              campoDropdown<Cliente>(
                "Cliente",
                clientes,
                clienteSeleccionado,
                    (v) => setState(() => clienteSeleccionado = v),
                mostrar: (c) => "${c.nombre} ${c.apellidoPaterno}",
              ),
              const SizedBox(height: 16),
              campoDropdown<Vehiculo>(
                "Vehículo",
                vehiculos,
                vehiculoSeleccionado,
                    (v) => setState(() => vehiculoSeleccionado = v),
                mostrar: (v) => "${v.marca} - ${v.modelo}",
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: guardarServicio, // Aquí se llamaría guardarServicio()
                icon: const Icon(Icons.save, color: Colors.black),
                label: const Text("Guardar Servicio",
                    style: TextStyle(color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> guardarServicio() async {
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Campos incompletos",
        text: "Por favor complete todos los campos.",
      );
      return;
    }

    if (clienteSeleccionado == null || vehiculoSeleccionado == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Error",
        text: "Debes seleccionar cliente y vehículo.",
      );
      return;
    }

    final nuevoServicio = Servicio(
      idServicio: widget.servicio?.idServicio ?? 0,
      fechaEntrada: fechaEntradaCtrl.text,
      fechaSalida: fechaSalidaCtrl.text,
      nombre: nombreSeleccionado!,
      tipo: tipoSeleccionado!,
      duracionEstimada: duracionCtrl.text,
      costoTotal: double.tryParse(costoCtrl.text),
      estado: estadoSeleccionado!,
      idCliente: clienteSeleccionado!.idCliente,
      idVehiculo: vehiculoSeleccionado!.idVehiculo,
    );

    try {
      bool exito;
      if (widget.servicio == null) {
        exito = await ServicioService().createServicio(nuevoServicio);
      } else {
        exito = await ServicioService()
            .updateServicio(nuevoServicio.idServicio!, nuevoServicio);
      }

      if (!mounted) return;

      if (exito) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Éxito",
          text: "Servicio guardado correctamente",
        );
        Navigator.pop(context, true);
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Error",
          text: "No se pudo guardar el servicio.",
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



  Widget campoTexto(String label, TextEditingController ctrl, IconData icon,
      {TextInputType teclado = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: teclado,
      decoration: deco(label, icon),
      validator: (v) => v == null || v.isEmpty ? "Campo obligatorio" : null,
    );
  }

  Widget campoFecha(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      decoration: deco(label, Icons.calendar_today),
      onTap: () => seleccionarFecha(ctrl),
      validator: (v) => v == null || v.isEmpty ? "Campo obligatorio" : null,
    );
  }

  Widget campoDropdown<T>(String label, List<T> items, T? valorSeleccionado,
      Function(T?) onChange,
      {String Function(T)? mostrar}) {
    return DropdownButtonFormField<T>(
      value: valorSeleccionado,
      decoration: deco(label, null),
      items: items
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(mostrar != null ? mostrar(e) : e.toString()),
      ))
          .toList(),
      onChanged: onChange,
      validator: (v) => v == null ? "Campo obligatorio" : null,
    );
  }

}

