import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../domain/entities/datos_cliente.dart';
import '../../domain/entities/estado_envio.dart';
import '../../domain/entities/item_carrito.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/producto.dart';
import '../../domain/errores/excepciones_dominio.dart';
import '../../domain/repositories/catalogo_repositorio.dart';
import '../../domain/repositories/rastreo_repositorio.dart';

/// Sujeto observable (patrón Observer) que concentra el estado en RAM del
/// catálogo, el carrito y el rastreo del último pedido.
///
/// Los widgets nunca modifican datos directamente: invocan métodos de este
/// controlador y se redibujan a través de `ListenableBuilder` cuando se
/// ejecuta `notifyListeners()`.
class CatalogoController extends ChangeNotifier {
  CatalogoController({required CatalogoRepositorio catalogoRepositorio, required RastreoRepositorio rastreoRepositorio})
    : _catalogoRepositorio = catalogoRepositorio,
      _rastreoRepositorio = rastreoRepositorio;

  final CatalogoRepositorio _catalogoRepositorio;
  final RastreoRepositorio _rastreoRepositorio;

  static const double tasaIva = 0.16;
  static const double costoEnvioBase = 49.0;
  static const double montoEnvioGratis = 500.0;

  List<Producto> _productos = const [];
  final Map<String, int> _carrito = {};
  String? _categoriaSeleccionada;
  bool _procesandoPago = false;

  Pedido? _ultimoPedido;
  EstadoEnvio? _ultimoEstadoEnvio;
  StreamSubscription<EstadoEnvio>? _suscripcionRastreo;
  final StreamController<EstadoEnvio> _flujoRastreo = StreamController<EstadoEnvio>.broadcast();

  // ---------------------------------------------------------------------------
  // Getters computados
  // ---------------------------------------------------------------------------

  UnmodifiableListView<Producto> get productos => UnmodifiableListView(_productos);

  bool get catalogoCargado => _productos.isNotEmpty;

  List<String> get categorias {
    final unicas = <String>{};
    for (final producto in _productos) {
      unicas.add(producto.categoria);
    }
    return List.unmodifiable(unicas);
  }

  String? get categoriaSeleccionada => _categoriaSeleccionada;

  /// Setter computado: valida la categoría y notifica a los observadores.
  set categoriaSeleccionada(String? valor) {
    final normalizado = (valor != null && categorias.contains(valor)) ? valor : null;
    if (normalizado == _categoriaSeleccionada) return;
    _categoriaSeleccionada = normalizado;
    notifyListeners();
  }

  List<Producto> get productosVisibles {
    final categoria = _categoriaSeleccionada;
    if (categoria == null) return productos;
    return List.unmodifiable(_productos.where((producto) => producto.categoria == categoria));
  }

  List<ItemCarrito> get itemsCarrito => List.unmodifiable([
    for (final producto in _productos)
      if ((_carrito[producto.id] ?? 0) > 0) ItemCarrito(producto: producto, cantidad: _carrito[producto.id]!),
  ]);

  bool get carritoVacio => _carrito.isEmpty;

  int get totalArticulos => _carrito.values.fold(0, (suma, cantidad) => suma + cantidad);

  double get subtotal => _redondear(itemsCarrito.fold<double>(0, (suma, item) => suma + item.subtotal));

  double get ahorroTotal => _redondear(itemsCarrito.fold<double>(0, (suma, item) => suma + item.ahorro));

  double get impuestos => _redondear(subtotal * tasaIva);

  double get costoEnvio => (carritoVacio || subtotal >= montoEnvioGratis) ? 0 : costoEnvioBase;

  double get total => _redondear(subtotal + impuestos + costoEnvio);

  bool get procesandoPago => _procesandoPago;

  Pedido? get ultimoPedido => _ultimoPedido;

  EstadoEnvio? get ultimoEstadoEnvio => _ultimoEstadoEnvio;

  /// Flujo de difusión con las lecturas GPS del último pedido.
  Stream<EstadoEnvio> get flujoRastreo => _flujoRastreo.stream;

  int cantidadEnCarrito(String productoId) => _carrito[productoId] ?? 0;

  /// Unidades que todavía pueden agregarse al carrito.
  int disponiblesPara(String productoId) {
    final producto = _buscar(productoId);
    return producto.stock - cantidadEnCarrito(productoId);
  }

  // ---------------------------------------------------------------------------
  // Operaciones asíncronas
  // ---------------------------------------------------------------------------

  Future<void> cargarCatalogo() async {
    final recibidos = await _catalogoRepositorio.obtenerProductos();
    _productos = List.unmodifiable(recibidos);
    _carrito.removeWhere((id, _) => !_productos.any((producto) => producto.id == id));
    if (_categoriaSeleccionada != null && !categorias.contains(_categoriaSeleccionada)) {
      _categoriaSeleccionada = null;
    }
    notifyListeners();
  }

  /// Cobra el carrito, descuenta el stock real en RAM, vacía el carrito y
  /// arranca el rastreo satelital del pedido.
  Future<Pedido> confirmarPago(DatosCliente cliente) async {
    if (_procesandoPago) throw const PagoEnCursoExcepcion();
    if (carritoVacio) throw const CarritoVacioExcepcion();
    _validarStockDelCarrito();

    final reservado = Map<String, int>.of(_carrito);
    final itemsReservados = itemsCarrito;
    final totalCobrado = total;

    _procesandoPago = true;
    notifyListeners();
    try {
      final pedidoId = await _catalogoRepositorio.procesarPago(cliente: cliente, total: totalCobrado);
      _validarStockDelCarrito();

      _productos = List.unmodifiable([
        for (final producto in _productos)
          reservado.containsKey(producto.id)
              ? producto.copyWith(stock: producto.stock - reservado[producto.id]!)
              : producto,
      ]);
      _carrito.clear();

      final pedido = Pedido(
        id: pedidoId,
        items: itemsReservados,
        total: totalCobrado,
        cliente: cliente,
        fecha: DateTime.now(),
      );
      _ultimoPedido = pedido;
      _iniciarRastreo(pedidoId);
      return pedido;
    } finally {
      _procesandoPago = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Mutaciones síncronas del carrito e inventario
  // ---------------------------------------------------------------------------

  /// Agrega unidades al carrito. Lanza [StockInsuficienteExcepcion] si la
  /// cantidad total supera el inventario real.
  void agregarAlCarrito(String productoId, {int unidades = 1}) {
    assert(unidades > 0, 'Se debe agregar al menos una unidad.');
    if (_procesandoPago) throw const PagoEnCursoExcepcion();
    final producto = _buscar(productoId);
    final enCarrito = cantidadEnCarrito(productoId);
    final solicitadas = enCarrito + unidades;
    if (solicitadas > producto.stock) {
      throw StockInsuficienteExcepcion(
        nombreProducto: producto.nombre,
        disponibles: producto.stock - enCarrito,
        solicitados: unidades,
      );
    }
    _carrito[productoId] = solicitadas;
    notifyListeners();
  }

  void disminuirDelCarrito(String productoId) {
    if (_procesandoPago) return;
    final actual = cantidadEnCarrito(productoId);
    if (actual == 0) return;
    if (actual == 1) {
      _carrito.remove(productoId);
    } else {
      _carrito[productoId] = actual - 1;
    }
    notifyListeners();
  }

  void eliminarDelCarrito(String productoId) {
    if (_procesandoPago) return;
    if (_carrito.remove(productoId) != null) notifyListeners();
  }

  /// Reabastece todo el inventario hasta su capacidad máxima en una sola
  /// mutación atómica seguida de una única notificación.
  void rellenarStock() {
    _productos = List.unmodifiable(_productos.map((producto) => producto.copyWith(stock: producto.capacidadMaxima)));
    notifyListeners();
  }

  void cerrarRastreo() {
    _suscripcionRastreo?.cancel();
    _suscripcionRastreo = null;
    _ultimoPedido = null;
    _ultimoEstadoEnvio = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Utilidades internas
  // ---------------------------------------------------------------------------

  void _iniciarRastreo(String pedidoId) {
    _suscripcionRastreo?.cancel();
    _ultimoEstadoEnvio = null;
    _suscripcionRastreo = _rastreoRepositorio
        .rastrearPedido(pedidoId)
        .listen(
          (estado) {
            _ultimoEstadoEnvio = estado;
            if (!_flujoRastreo.isClosed) _flujoRastreo.add(estado);
          },
          onError: (Object error, StackTrace traza) {
            if (!_flujoRastreo.isClosed) _flujoRastreo.addError(error, traza);
          },
        );
  }

  void _validarStockDelCarrito() {
    for (final entrada in _carrito.entries) {
      final producto = _buscar(entrada.key);
      if (entrada.value > producto.stock) {
        throw StockInsuficienteExcepcion(
          nombreProducto: producto.nombre,
          disponibles: producto.stock,
          solicitados: entrada.value,
        );
      }
    }
  }

  Producto _buscar(String productoId) => _productos.firstWhere(
    (producto) => producto.id == productoId,
    orElse: () => throw ArgumentError.value(productoId, 'productoId', 'Producto inexistente'),
  );

  static double _redondear(double valor) => (valor * 100).roundToDouble() / 100;

  @override
  void dispose() {
    _suscripcionRastreo?.cancel();
    _flujoRastreo.close();
    super.dispose();
  }
}
