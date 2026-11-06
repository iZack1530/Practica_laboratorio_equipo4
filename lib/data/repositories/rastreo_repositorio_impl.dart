import '../../domain/entities/estado_envio.dart';
import '../../domain/repositories/rastreo_repositorio.dart';
import '../datasources/gps_fuente_simulada.dart';

/// Implementación concreta del repositorio de rastreo satelital.
class RastreoRepositorioImpl implements RastreoRepositorio {
  RastreoRepositorioImpl(this._fuente);

  final GpsFuenteSimulada _fuente;

  @override
  Stream<EstadoEnvio> rastrearPedido(String pedidoId) => _fuente.rastrear(pedidoId);
}
