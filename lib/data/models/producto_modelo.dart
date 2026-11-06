import '../../domain/entities/producto.dart';

/// Modelo de la capa de datos que sabe convertir registros crudos (mapas)
/// en entidades del dominio.
class ProductoModelo extends Producto {
  ProductoModelo({
    required super.id,
    required super.nombre,
    required super.categoria,
    required super.precio,
    required super.stock,
    required super.capacidadMaxima,
    required super.imagenUrl,
    super.descripcion,
    super.porcentajeDescuento,
  });

  factory ProductoModelo.desdeMapa(Map<String, dynamic> mapa) {
    return ProductoModelo(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      categoria: mapa['categoria'] as String,
      precio: (mapa['precio'] as num).toDouble(),
      stock: (mapa['stock'] as num).toInt(),
      capacidadMaxima: (mapa['capacidadMaxima'] as num).toInt(),
      imagenUrl: mapa['imagenUrl'] as String,
      descripcion: mapa['descripcion'] as String?,
      porcentajeDescuento: (mapa['porcentajeDescuento'] as num?)?.toDouble(),
    );
  }
}
