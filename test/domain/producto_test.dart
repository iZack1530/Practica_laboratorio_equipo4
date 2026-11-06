import 'package:ecomarket_app/domain/entities/item_carrito.dart';
import 'package:ecomarket_app/domain/entities/producto.dart';
import 'package:flutter_test/flutter_test.dart';

Producto _producto({double precio = 100, int stock = 5, int capacidad = 10, double? descuento}) => Producto(
  id: 'x',
  nombre: 'Producto',
  categoria: 'Hogar',
  precio: precio,
  stock: stock,
  capacidadMaxima: capacidad,
  imagenUrl: 'https://ejemplo.invalid/x.png',
  porcentajeDescuento: descuento,
);

void main() {
  group('Producto (aserciones del constructor)', () {
    test('rechaza un precio negativo', () {
      expect(() => _producto(precio: -1), throwsA(isA<AssertionError>()));
    });

    test('rechaza un stock negativo', () {
      expect(() => _producto(stock: -3), throwsA(isA<AssertionError>()));
    });

    test('rechaza un stock mayor a la capacidad', () {
      expect(() => _producto(stock: 11, capacidad: 10), throwsA(isA<AssertionError>()));
    });

    test('rechaza descuentos fuera de rango', () {
      expect(() => _producto(descuento: 120), throwsA(isA<AssertionError>()));
    });
  });

  group('Producto (getters computados)', () {
    test('calcula el precio final con descuento', () {
      final producto = _producto(precio: 389, descuento: 15);
      expect(producto.tieneDescuento, isTrue);
      expect(producto.precioFinal, 330.65);
    });

    test('detecta agotado y stock bajo', () {
      expect(_producto(stock: 0).estaAgotado, isTrue);
      expect(_producto(stock: 2).tieneStockBajo, isTrue);
      expect(_producto(stock: 8).tieneStockBajo, isFalse);
    });

    test('copyWith crea una nueva instancia sin mutar la original', () {
      final original = _producto(stock: 5);
      final copia = original.copyWith(stock: 2);
      expect(original.stock, 5);
      expect(copia.stock, 2);
      expect(copia.id, original.id);
    });

    test('descripción segura cuando es nula', () {
      expect(_producto().descripcionSegura, 'Sin descripción disponible.');
    });
  });

  test('ItemCarrito calcula su subtotal', () {
    final item = ItemCarrito(producto: _producto(precio: 50, descuento: 10), cantidad: 3);
    expect(item.subtotal, 135);
  });
}
