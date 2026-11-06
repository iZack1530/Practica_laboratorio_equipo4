import '../entities/estado_envio.dart';

/// Contrato del dominio para el monitoreo satelital de pedidos.
abstract interface class RastreoRepositorio {
  /// Flujo continuo de lecturas GPS hasta que el pedido es entregado.
  Stream<EstadoEnvio> rastrearPedido(String pedidoId);
}
