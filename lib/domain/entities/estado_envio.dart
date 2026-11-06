/// Etapas por las que pasa un pedido durante su traslado.
enum EtapaEnvio { preparando, enCamino, cercaDeTi, entregado }

/// Lectura inmutable del GPS satelital del repartidor.
class EstadoEnvio {
  const EstadoEnvio({
    required this.pedidoId,
    required this.minutosRestantes,
    required this.minutosTotales,
    required this.latitud,
    required this.longitud,
    required this.actualizadoEn,
  }) : assert(minutosRestantes >= 0, 'Los minutos restantes no pueden ser negativos.'),
       assert(minutosTotales > 0, 'El tiempo total estimado debe ser mayor a cero.'),
       assert(latitud >= -90 && latitud <= 90, 'Latitud fuera de rango.'),
       assert(longitud >= -180 && longitud <= 180, 'Longitud fuera de rango.');

  final String pedidoId;
  final int minutosRestantes;
  final int minutosTotales;
  final double latitud;
  final double longitud;
  final DateTime actualizadoEn;

  bool get entregado => minutosRestantes == 0;

  /// Avance del traslado entre 0.0 y 1.0.
  double get progreso => (1 - minutosRestantes / minutosTotales).clamp(0.0, 1.0);

  EtapaEnvio get etapa {
    if (entregado) return EtapaEnvio.entregado;
    if (progreso < 0.15) return EtapaEnvio.preparando;
    if (minutosRestantes <= 3) return EtapaEnvio.cercaDeTi;
    return EtapaEnvio.enCamino;
  }
}
