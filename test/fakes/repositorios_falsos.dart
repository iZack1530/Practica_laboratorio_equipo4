import 'dart:async';

import 'package:ecomarket_app/domain/entities/datos_cliente.dart';
import 'package:ecomarket_app/domain/entities/estado_envio.dart';
import 'package:ecomarket_app/domain/entities/producto.dart';
import 'package:ecomarket_app/domain/repositories/catalogo_repositorio.dart';
import 'package:ecomarket_app/domain/repositories/rastreo_repositorio.dart';

/// Productos de prueba con stock controlado.
List<Producto> productosDePrueba() => [
  Producto(
    id: 'a',
    nombre: 'Termo de bambú',
    categoria: 'Accesorios',
    precio: 100,
    stock: 1,
    capacidadMaxima: 5,
    imagenUrl: 'https://ejemplo.invalid/a.png',
  ),
  Producto(
    id: 'b',
    nombre: 'Jabón natural',
    categoria: 'Cuidado personal',
    precio: 50,
    stock: 4,
    capacidadMaxima: 10,
    imagenUrl: 'https://ejemplo.invalid/b.png',
    porcentajeDescuento: 10,
  ),
  Producto(
    id: 'c',
    nombre: 'Composta',
    categoria: 'Jardín',
    precio: 300,
    stock: 0,
    capacidadMaxima: 3,
    imagenUrl: 'https://ejemplo.invalid/c.png',
  ),
];

class RepositorioCatalogoFalso implements CatalogoRepositorio {
  int pagosProcesados = 0;

  @override
  Future<List<Producto>> obtenerProductos() => Future.value(productosDePrueba());

  @override
  Future<String> procesarPago({required DatosCliente cliente, required double total}) {
    pagosProcesados++;
    return Future.value('PRUEBA-$pagosProcesados');
  }
}

class RepositorioRastreoFalso implements RastreoRepositorio {
  final StreamController<EstadoEnvio> emisor = StreamController<EstadoEnvio>();

  @override
  Stream<EstadoEnvio> rastrearPedido(String pedidoId) => emisor.stream;
}

const DatosCliente clienteDePrueba = DatosCliente(
  nombreCompleto: 'Ana López',
  correo: 'ana@correo.com',
  telefono: '5512345678',
  direccion: 'Av. Reforma 123',
  codigoPostal: '06600',
  terminacionTarjeta: '4242',
);
