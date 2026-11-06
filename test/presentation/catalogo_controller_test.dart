import 'package:ecomarket_app/domain/entities/estado_envio.dart';
import 'package:ecomarket_app/domain/errores/excepciones_dominio.dart';
import 'package:ecomarket_app/presentation/controllers/catalogo_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/repositorios_falsos.dart';

void main() {
  late RepositorioCatalogoFalso catalogo;
  late RepositorioRastreoFalso rastreo;
  late CatalogoController controller;

  setUp(() async {
    catalogo = RepositorioCatalogoFalso();
    rastreo = RepositorioRastreoFalso();
    controller = CatalogoController(catalogoRepositorio: catalogo, rastreoRepositorio: rastreo);
    await controller.cargarCatalogo();
  });

  tearDown(() => controller.dispose());

  test('carga el catálogo y expone las categorías', () {
    expect(controller.productos, hasLength(3));
    expect(controller.categorias, ['Accesorios', 'Cuidado personal', 'Jardín']);
  });

  test('el setter de categoría filtra y notifica', () {
    var notificaciones = 0;
    controller.addListener(() => notificaciones++);
    controller.categoriaSeleccionada = 'Jardín';
    expect(controller.productosVisibles.map((p) => p.id), ['c']);
    controller.categoriaSeleccionada = 'Inexistente';
    expect(controller.categoriaSeleccionada, isNull);
    expect(notificaciones, 2);
  });

  test('lanza StockInsuficienteExcepcion al superar el inventario', () {
    controller.agregarAlCarrito('a');
    expect(() => controller.agregarAlCarrito('a'), throwsA(isA<StockInsuficienteExcepcion>()));
    expect(() => controller.agregarAlCarrito('c'), throwsA(isA<StockInsuficienteExcepcion>()));
    expect(controller.cantidadEnCarrito('a'), 1);
  });

  test('calcula subtotal, IVA, envío y total', () {
    controller.agregarAlCarrito('a'); // 100.00
    controller.agregarAlCarrito('b', unidades: 2); // 45.00 x 2 = 90.00
    expect(controller.subtotal, 190);
    expect(controller.ahorroTotal, 10);
    expect(controller.impuestos, 30.4);
    expect(controller.costoEnvio, CatalogoController.costoEnvioBase);
    expect(controller.total, 269.4);
  });

  test('el pago descuenta stock real, vacía el carrito e inicia el rastreo', () async {
    controller.agregarAlCarrito('b', unidades: 3);
    final pedido = await controller.confirmarPago(clienteDePrueba);

    expect(pedido.id, 'PRUEBA-1');
    expect(pedido.totalArticulos, 3);
    expect(controller.carritoVacio, isTrue);
    expect(controller.productos.firstWhere((p) => p.id == 'b').stock, 1);
    expect(controller.ultimoPedido?.id, 'PRUEBA-1');

    final lectura = EstadoEnvio(
      pedidoId: 'PRUEBA-1',
      minutosRestantes: 5,
      minutosTotales: 12,
      latitud: 19.4,
      longitud: -99.1,
      actualizadoEn: DateTime(2026),
    );
    final siguiente = controller.flujoRastreo.first;
    rastreo.emisor.add(lectura);
    expect((await siguiente).minutosRestantes, 5);
    expect(controller.ultimoEstadoEnvio?.minutosRestantes, 5);
  });

  test('no permite pagar un carrito vacío', () {
    expect(controller.confirmarPago(clienteDePrueba), throwsA(isA<CarritoVacioExcepcion>()));
  });

  test('rellenar stock restaura la capacidad máxima con una sola notificación', () {
    var notificaciones = 0;
    controller.addListener(() => notificaciones++);
    controller.rellenarStock();
    expect(controller.productos.every((p) => p.stock == p.capacidadMaxima), isTrue);
    expect(notificaciones, 1);
  });
}
