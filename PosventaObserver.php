<?php

namespace App\Observers;

use App\Models\Posventa;
use App\Models\Alertas;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class PosventaObserver
{
    private $rangosKm = [
        5000 => "Primeros 5,000 km: Cambio de aceite y filtros, más inspección general del vehículo.",
        10000 => "10,000 km: Inspección general (frenos, suspensión, dirección, batería y sistema eléctrico). Cambio de aceite y filtros.",
        20000 => "20,000 km: Revisar aire acondicionado, transmisión y llantas. Incluye tareas previas.",
        30000 => "30,000 km: Verificación del sistema de escape, sistema de combustible y cinturones de seguridad.",
        40000 => "40,000 km: Inspección detallada de la suspensión y dirección.",
        50000 => "50,000 km: Inspección completa (frenos, transmisión, suspensión, dirección, batería y sistema eléctrico).",
    ];

    // Función auxiliar para manejar fechas
    private function parseFecha($fecha)
    {
        if (!$fecha) return null;
        try {
            return $fecha instanceof Carbon ? $fecha : Carbon::parse($fecha);
        } catch (\Exception $e) {
            return null;
        }
    }

    /**
     * Crear alerta sin duplicados
     */
    private function crearAlerta(Posventa $posventa, $tipo, $mensaje)
    {
        // 1. Validar duplicados (Tu código original)
        $yaExiste = Alertas::where('id_posventa', $posventa->id_posventa)
            ->where('tipo', $tipo)
            ->whereDate('fecha_alerta', now()->toDateString())
            ->exists();

        if ($yaExiste) {
            Log::info("⏳ Alerta duplicada prevenida: {$tipo}");
            return;
        }

        // 2. OBTENER IDS DESDE LA RELACIÓN SERVICIO
        // Como Posventa no tiene cliente ni vehículo, los sacamos del Servicio padre.
        $servicio = $posventa->servicio;

        // Si la relación no vino cargada, la cargamos ahora
        if (!$servicio) {
            $posventa->load('servicio');
            $servicio = $posventa->servicio;
        }

        // Extraemos los IDs del servicio encontrado
        $idCliente  = $servicio ? $servicio->id_cliente : null;
        $idVehiculo = $servicio ? $servicio->id_vehiculo : null;
        
        // Log para depuración (opcional)
        if (!$servicio) {
            Log::error("❌ Error: La posventa ID {$posventa->id_posventa} no tiene un servicio asociado válido.");
        }

        // 3. Crear la alerta con los datos correctos
        Alertas::create([
            'id_cliente'   => $idCliente,   // ¡Ahora sí tendrá valor!
            'id_vehiculo'  => $idVehiculo,  // ¡Ahora sí tendrá valor!
            'id_posventa'  => $posventa->id_posventa,
            'id_servicio'  => $posventa->id_servicio, // También guardamos el servicio si quieres
            'tipo'         => $tipo,
            'mensaje'      => $mensaje,
            'fecha_alerta' => now(),
            'estatus'      => 'Pendiente'
        ]);

        Log::info("✅ Alerta creada: {$tipo} | Cliente: {$idCliente} | Vehículo: {$idVehiculo}");
    }
   public function created(Posventa $posventa)
    {
        // =======================================================
        // PASO 1: CONSEGUIR LOS IDs (CLIENTE Y VEHICULO)
        // =======================================================
        // Tu tabla posventas solo tiene id_servicio. 
        // Accedemos al servicio para sacar los datos del cliente y vehiculo.
        
        $servicio = $posventa->servicio; 
        
        // Si la relación no está cargada, la forzamos
        if (!$servicio) {
            $posventa->load('servicio');
            $servicio = $posventa->servicio;
        }

        // Extraemos los IDs. Si no hay servicio, quedarán como null.
        $idCliente  = $servicio ? $servicio->id_cliente : null;
        $idVehiculo = $servicio ? $servicio->id_vehiculo : null;
        $idServicio = $posventa->id_servicio;

        // =======================================================
        // PASO 2: TRADUCIR EL MOTIVO (Posventa -> Alerta)
        // =======================================================
        // Aquí convertimos lo que dice tu tabla 'posventas' a lo que 
        // OBLIGATORIAMENTE pide tu tabla 'alertas' (tu ENUM).

        $motivoOriginal = $posventa->motivo_contacto;
        
        // Valores por defecto
        $tipoAlerta = 'Recordatorio de mantenimiento'; 
        $mensaje = 'Tienes una notificación del taller.';

        switch ($motivoOriginal) {
            case 'Encuesta de satisfacción':
                // En BD Alertas se llama diferente, así que lo traducimos:
                $tipoAlerta = 'Encuesta de satisfacción pendiente';
                $mensaje = 'Ayúdanos a mejorar contestando esta breve encuesta.';
                break;

            case 'Reclamación':
                $tipoAlerta = 'Reclamación pendiente';
                $mensaje = 'Hay actualizaciones sobre tu reclamación.';
                break;

            case 'Garantía':
                $tipoAlerta = 'Garantía por vencer';
                $mensaje = 'Atención: Tu garantía está próxima a vencer.';
                break;

            case 'Recordatorio de mantenimiento':
                $tipoAlerta = 'Recordatorio de mantenimiento';
                $mensaje = 'Tu vehículo tiene una revisión programada para hoy.';
                break;
                
            case 'Otro':
                // Puedes decidir qué hacer aquí, o usar un genérico
                $tipoAlerta = 'Recordatorio de mantenimiento';
                $mensaje = 'Tienes un mensaje general del taller: ' . ($posventa->observaciones ?? '');
                break;
        }

        // =======================================================
        // PASO 3: CREAR LA ALERTA (Solo si la fecha es HOY)
        // =======================================================
        
        $fechaProgramada = $this->parseFecha($posventa->proxima_revision);

        // Verificamos si existe fecha y si es IGUAL a hoy
        if ($fechaProgramada && $fechaProgramada->toDateString() === now()->toDateString()) {
            
            // Evitamos duplicados: No crear si ya existe una alerta igual hoy
            $yaExiste = Alertas::where('id_posventa', $posventa->id_posventa)
                ->where('tipo', $tipoAlerta)
                ->whereDate('fecha_alerta', now()->toDateString())
                ->exists();

            if (!$yaExiste) {
                Alertas::create([
                    'id_cliente'   => $idCliente,   // Ya no será NULL
                    'id_vehiculo'  => $idVehiculo,  // Ya no será NULL
                    'id_servicio'  => $idServicio,
                    'id_posventa'  => $posventa->id_posventa,
                    'tipo'         => $tipoAlerta,  // Usamos el texto traducido
                    'mensaje'      => $mensaje,
                    'fecha_alerta' => now(),
                    'estatus'      => 'Pendiente'
                ]);

                Log::info("✅ Alerta creada: $tipoAlerta (Cliente: $idCliente, Vehiculo: $idVehiculo)");
            }
        }
    }


    public function updated(Posventa $posventa)
    {
        $fecha = $this->parseFecha($posventa->proxima_revision);

        // CAMBIO DE FECHA → ALERTA
        if ($posventa->isDirty('proxima_revision')) {
            if ($fecha && $fecha->toDateString() === now()->toDateString()) {
                Log::info("⚠️ Revisión HOY (UPDATE) posventa {$posventa->id_posventa}");
                $this->crearAlerta(
                    $posventa,
                    'Mantenimiento por fecha',
                    'La revisión programada es HOY.'
                );
            }
        }

        // CAMBIO DE KM → ALERTA
        if ($posventa->isDirty('kilometraje')) {
            $km = (int) $posventa->kilometraje;

            if (isset($this->rangosKm[$km])) {
                Log::info("⚠️ KM {$km} (UPDATE) posventa {$posventa->id_posventa}");
                $this->crearAlerta(
                    $posventa,
                    'Mantenimiento por kilometraje',
                    $this->rangosKm[$km]
                );
            }
        }

        
    }
}
