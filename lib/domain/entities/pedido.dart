import 'datos_cliente.dart';
import 'item_carrito.dart';

/// Pedido confirmado e inmutable que resulta de un pago aprobado.
class Pedido {
  Pedido({
    required this.id,
    required List<ItemCarrito> items,
    required this.total,
    required this.cliente,
    required this.fecha,
  }) : assert(items.isNotEmpty, 'Un pedido debe contener al menos un artículo.'),
       assert(total >= 0, 'El total de un pedido no puede ser negativo.'),
       items = List.unmodifiable(items);

  final String id;
  final List<ItemCarrito> items;
  final double total;
  final DatosCliente cliente;
  final DateTime fecha;

  int get totalArticulos => items.fold(0, (suma, item) => suma + item.cantidad);
}
