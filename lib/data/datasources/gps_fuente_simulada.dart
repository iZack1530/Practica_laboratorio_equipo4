import 'dart:math' as math;

import '../../domain/entities/estado_envio.dart';

/// Emulador de un receptor GPS satelital.
///
/// Emite una lectura inmediata y después una nueva cada [intervalo]
/// (3 segundos por defecto). En cada ciclo descuenta un minuto del tiempo
/// estimado de entrega y desplaza las coordenadas hacia el destino.
class GpsFuenteSimulada {
  GpsFuenteSimulada({this.intervalo = const Duration(seconds: 3), this.minutosEstimados = 12, math.Random? aleatorio})
    : assert(minutosEstimados > 0, 'El tiempo estimado debe ser mayor a cero.'),
      _aleatorio = aleatorio ?? math.Random();

  final Duration intervalo;
  final int minutosEstimados;
  final math.Random _aleatorio;

  // Centro de distribución y punto de entrega (Ciudad de México).
  static const double _latitudOrigen = 19.4326;
  static const double _longitudOrigen = -99.1332;
  static const double _latitudDestino = 19.3910;
  static const double _longitudDestino = -99.1700;

  Stream<EstadoEnvio> rastrear(String pedidoId) async* {
    for (var restantes = minutosEstimados; restantes >= 0; restantes--) {
      if (restantes < minutosEstimados) {
        await Future<void>.delayed(intervalo);
      }
      final avance = 1 - restantes / minutosEstimados;
      yield EstadoEnvio(
        pedidoId: pedidoId,
        minutosRestantes: restantes,
        minutosTotales: minutosEstimados,
        latitud: _interpolar(_latitudOrigen, _latitudDestino, avance, restantes),
        longitud: _interpolar(_longitudOrigen, _longitudDestino, avance, restantes),
        actualizadoEn: DateTime.now(),
      );
    }
  }

  /// Interpolación lineal con una pequeña variación que simula el ruido
  /// natural de la señal satelital. Al llegar al destino no hay variación.
  double _interpolar(double origen, double destino, double avance, int restantes) {
    final ruido = restantes == 0 ? 0.0 : (_aleatorio.nextDouble() - 0.5) * 0.0008;
    return origen + (destino - origen) * avance + ruido;
  }
}
