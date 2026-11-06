import '../../domain/entities/datos_cliente.dart';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/catalogo_repositorio.dart';
import '../datasources/catalogo_fuente_simulada.dart';
import '../models/producto_modelo.dart';

/// Implementación concreta del repositorio de catálogo.
class CatalogoRepositorioImpl implements CatalogoRepositorio {
  CatalogoRepositorioImpl(this._fuente);

  final CatalogoFuenteSimulada _fuente;

  @override
  Future<List<Producto>> obtenerProductos() async {
    final registros = await _fuente.obtenerProductosCrudos();
    return registros.map(ProductoModelo.desdeMapa).toList(growable: false);
  }

  @override
  Future<String> procesarPago({required DatosCliente cliente, required double total}) {
    return _fuente.registrarPago(total: total);
  }
}
