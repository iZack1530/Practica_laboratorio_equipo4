import 'producto.dart';

/// Línea inmutable del carrito: un producto y la cantidad solicitada.
class ItemCarrito {
  const ItemCarrito({required this.producto, required this.cantidad})
    : assert(cantidad > 0, 'La cantidad de un artículo en el carrito debe ser mayor a cero.');

  final Producto producto;
  final int cantidad;

  double get subtotal => ((producto.precioFinal * cantidad) * 100).roundToDouble() / 100;

  double get ahorro => ((producto.ahorroPorUnidad * cantidad) * 100).roundToDouble() / 100;
}
