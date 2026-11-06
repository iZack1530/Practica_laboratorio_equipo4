import 'dart:math' as math;

/// Entidad inmutable del dominio que representa un artículo ecológico.
///
/// El constructor está blindado en dos niveles:
/// 1. Aserciones (`assert`) que detienen la ejecución en modo desarrollo
///    cuando se intenta construir un producto con datos inválidos.
/// 2. Normalización dentro de la lista de inicialización, para que en modo
///    release ningún valor negativo llegue a la memoria de la aplicación.
class Producto {
  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required double precio,
    required int stock,
    required int capacidadMaxima,
    required this.imagenUrl,
    this.descripcion,
    double? porcentajeDescuento,
  }) : assert(id.trim().isNotEmpty, 'El identificador del producto no puede estar vacío.'),
       assert(nombre.trim().isNotEmpty, 'El nombre del producto no puede estar vacío.'),
       assert(precio >= 0, 'El precio no puede ser negativo.'),
       assert(stock >= 0, 'El stock no puede ser negativo.'),
       assert(capacidadMaxima >= 0, 'La capacidad máxima no puede ser negativa.'),
       assert(stock <= capacidadMaxima, 'El stock no puede superar la capacidad máxima del almacén.'),
       assert(
         porcentajeDescuento == null || (porcentajeDescuento >= 0 && porcentajeDescuento <= 100),
         'El porcentaje de descuento debe estar entre 0 y 100.',
       ),
       precio = precio < 0 ? 0.0 : precio,
       capacidadMaxima = math.max(capacidadMaxima, 0),
       stock = math.min(math.max(stock, 0), math.max(capacidadMaxima, 0)),
       porcentajeDescuento = porcentajeDescuento?.clamp(0, 100).toDouble();

  final String id;
  final String nombre;
  final String categoria;
  final double precio;
  final int stock;
  final int capacidadMaxima;
  final String imagenUrl;
  final String? descripcion;
  final double? porcentajeDescuento;

  /// Umbral a partir del cual se considera que quedan pocas unidades.
  static const int umbralStockBajo = 3;

  bool get tieneDescuento => (porcentajeDescuento ?? 0) > 0;

  bool get estaAgotado => stock == 0;

  bool get tieneStockBajo => stock > 0 && stock <= umbralStockBajo;

  /// Precio final con el descuento aplicado y redondeado a centavos.
  double get precioFinal {
    final descuento = porcentajeDescuento ?? 0;
    return ((precio * (1 - descuento / 100)) * 100).roundToDouble() / 100;
  }

  double get ahorroPorUnidad => precio - precioFinal;

  String get descripcionSegura {
    final texto = descripcion?.trim();
    return (texto == null || texto.isEmpty) ? 'Sin descripción disponible.' : texto;
  }

  Producto copyWith({
    String? nombre,
    String? categoria,
    double? precio,
    int? stock,
    int? capacidadMaxima,
    String? imagenUrl,
    String? descripcion,
    double? porcentajeDescuento,
  }) {
    return Producto(
      id: id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      descripcion: descripcion ?? this.descripcion,
      porcentajeDescuento: porcentajeDescuento ?? this.porcentajeDescuento,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Producto && other.id == id && other.stock == stock && other.precio == precio;

  @override
  int get hashCode => Object.hash(id, stock, precio);

  @override
  String toString() => 'Producto(id: $id, nombre: $nombre, stock: $stock/$capacidadMaxima)';
}
