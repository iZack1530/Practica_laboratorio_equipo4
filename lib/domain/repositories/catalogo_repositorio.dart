import '../entities/datos_cliente.dart';
import '../entities/producto.dart';

/// Contrato del dominio para obtener el catálogo y procesar pagos.
///
/// La capa de presentación sólo conoce esta abstracción; la implementación
/// concreta vive en la capa de datos.
abstract interface class CatalogoRepositorio {
  Future<List<Producto>> obtenerProductos();

  /// Procesa el cobro y devuelve el identificador del pedido generado.
  Future<String> procesarPago({required DatosCliente cliente, required double total});
}
