/// Excepción base de las reglas de negocio de EcoMarket.
sealed class ExcepcionDominio implements Exception {
  const ExcepcionDominio();

  String get mensaje;

  @override
  String toString() => mensaje;
}

/// Se lanza cuando se solicitan más unidades de las que existen en inventario.
final class StockInsuficienteExcepcion extends ExcepcionDominio {
  const StockInsuficienteExcepcion({
    required this.nombreProducto,
    required this.disponibles,
    required this.solicitados,
  });

  final String nombreProducto;
  final int disponibles;
  final int solicitados;

  @override
  String get mensaje => disponibles <= 0
      ? 'Stock insuficiente: "$nombreProducto" no tiene unidades disponibles.'
      : 'Stock insuficiente: solo quedan $disponibles unidades de "$nombreProducto".';
}

/// Se lanza al intentar pagar un carrito sin artículos.
final class CarritoVacioExcepcion extends ExcepcionDominio {
  const CarritoVacioExcepcion();

  @override
  String get mensaje => 'El carrito está vacío. Agrega productos antes de pagar.';
}

/// Se lanza cuando ya existe un pago en curso.
final class PagoEnCursoExcepcion extends ExcepcionDominio {
  const PagoEnCursoExcepcion();

  @override
  String get mensaje => 'Ya hay un pago en proceso. Espera a que termine.';
}
