import 'package:ecomarket_app/presentation/validadores/validadores_checkout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nombre requiere nombre y apellido con letras', () {
    expect(ValidadoresCheckout.nombre(''), isNotNull);
    expect(ValidadoresCheckout.nombre('Ana'), isNotNull);
    expect(ValidadoresCheckout.nombre('Ana123 López'), isNotNull);
    expect(ValidadoresCheckout.nombre('Ana López Núñez'), isNull);
  });

  test('correo con formato válido', () {
    expect(ValidadoresCheckout.correo('ana@'), isNotNull);
    expect(ValidadoresCheckout.correo('ana.lopez@escuela.edu.mx'), isNull);
  });

  test('teléfono y código postal', () {
    expect(ValidadoresCheckout.telefono('55123'), isNotNull);
    expect(ValidadoresCheckout.telefono('5512345678'), isNull);
    expect(ValidadoresCheckout.codigoPostal('0660'), isNotNull);
    expect(ValidadoresCheckout.codigoPostal('06600'), isNull);
  });

  test('dirección debe incluir número', () {
    expect(ValidadoresCheckout.direccion('Av. Reforma'), isNotNull);
    expect(ValidadoresCheckout.direccion('Av. Reforma 123'), isNull);
  });

  test('tarjeta con 16 dígitos y algoritmo de Luhn', () {
    expect(ValidadoresCheckout.tarjeta('4242 4242 4242 4241'), isNotNull);
    expect(ValidadoresCheckout.tarjeta('4242 4242'), isNotNull);
    expect(ValidadoresCheckout.tarjeta('4242 4242 4242 4242'), isNull);
  });

  test('vencimiento con formato MM/AA y no vencido', () {
    final referencia = DateTime(2026, 11, 5);
    expect(ValidadoresCheckout.vencimiento('13/27', ahora: referencia), isNotNull);
    expect(ValidadoresCheckout.vencimiento('10/26', ahora: referencia), isNotNull);
    expect(ValidadoresCheckout.vencimiento('11/26', ahora: referencia), isNull);
    expect(ValidadoresCheckout.vencimiento('01/30', ahora: referencia), isNull);
  });

  test('CVV de 3 o 4 dígitos', () {
    expect(ValidadoresCheckout.cvv('12'), isNotNull);
    expect(ValidadoresCheckout.cvv('123'), isNull);
  });
}
