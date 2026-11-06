/// Fuente de datos remota simulada.
///
/// Cada operación usa un `Future` retardado (1 segundo por defecto) para
/// reproducir la latencia de red de un servidor real sin bloquear la UI.
class CatalogoFuenteSimulada {
  CatalogoFuenteSimulada({this.retardo = const Duration(seconds: 1)});

  final Duration retardo;

  Future<List<Map<String, dynamic>>> obtenerProductosCrudos() async {
    await Future<void>.delayed(retardo);
    return _registros.map(Map<String, dynamic>.of).toList(growable: false);
  }

  Future<String> registrarPago({required double total}) async {
    await Future<void>.delayed(retardo);
    if (total <= 0) {
      throw StateError('El servidor rechazó un cobro con monto inválido.');
    }
    final marca = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'ECO-$marca';
  }

  static String _imagen(String semilla) => 'https://picsum.photos/seed/ecomarket-$semilla/480/480';

  /// Inventario inicial. Algunos artículos inician con poco o ningún stock
  /// para poder realizar la prueba de estrés de la evaluación.
  static final List<Map<String, dynamic>> _registros = [
    {
      'id': 'p01',
      'nombre': 'Cepillo dental de bambú',
      'categoria': 'Cuidado personal',
      'precio': 45.0,
      'stock': 12,
      'capacidadMaxima': 20,
      'imagenUrl': _imagen('cepillo'),
      'descripcion': 'Mango 100 % biodegradable y cerdas libres de BPA.',
      'porcentajeDescuento': null,
    },
    {
      'id': 'p02',
      'nombre': 'Botella térmica de acero 750 ml',
      'categoria': 'Accesorios',
      'precio': 389.0,
      'stock': 2,
      'capacidadMaxima': 10,
      'imagenUrl': _imagen('botella'),
      'descripcion': 'Mantiene bebidas frías 24 h y calientes 12 h.',
      'porcentajeDescuento': 15.0,
    },
    {
      'id': 'p03',
      'nombre': 'Bolsas reutilizables de algodón (3 pzas)',
      'categoria': 'Hogar',
      'precio': 159.0,
      'stock': 0,
      'capacidadMaxima': 15,
      'imagenUrl': _imagen('bolsas'),
      'descripcion': 'Algodón orgánico certificado, lavables en lavadora.',
      'porcentajeDescuento': null,
    },
    {
      'id': 'p04',
      'nombre': 'Jabón artesanal de avena',
      'categoria': 'Cuidado personal',
      'precio': 65.0,
      'stock': 1,
      'capacidadMaxima': 25,
      'imagenUrl': _imagen('jabon'),
      'descripcion': null,
      'porcentajeDescuento': null,
    },
    {
      'id': 'p05',
      'nombre': 'Café orgánico de Chiapas 500 g',
      'categoria': 'Alimentos',
      'precio': 245.0,
      'stock': 8,
      'capacidadMaxima': 12,
      'imagenUrl': _imagen('cafe'),
      'descripcion': 'Tueste medio, cultivado bajo sombra por cooperativas locales.',
      'porcentajeDescuento': 10.0,
    },
    {
      'id': 'p06',
      'nombre': 'Kit de huerto urbano',
      'categoria': 'Jardín',
      'precio': 520.0,
      'stock': 4,
      'capacidadMaxima': 6,
      'imagenUrl': _imagen('huerto'),
      'descripcion': 'Incluye macetas de fibra de coco, sustrato y 5 tipos de semillas.',
      'porcentajeDescuento': null,
    },
    {
      'id': 'p07',
      'nombre': 'Compostera doméstica 20 L',
      'categoria': 'Jardín',
      'precio': 699.0,
      'stock': 3,
      'capacidadMaxima': 5,
      // URL intencionalmente inválida para demostrar el errorBuilder.
      'imagenUrl': 'https://imagenes.ecomarket.invalid/compostera.png',
      'descripcion': 'Convierte residuos orgánicos en abono en 8 semanas.',
      'porcentajeDescuento': 20.0,
    },
    {
      'id': 'p08',
      'nombre': 'Miel de abeja melipona 250 g',
      'categoria': 'Alimentos',
      'precio': 180.0,
      'stock': 6,
      'capacidadMaxima': 10,
      'imagenUrl': _imagen('miel'),
      'descripcion': 'Miel cruda de abejas nativas sin aguijón de Yucatán.',
      'porcentajeDescuento': null,
    },
    {
      'id': 'p09',
      'nombre': 'Juego de cubiertos de bambú',
      'categoria': 'Accesorios',
      'precio': 120.0,
      'stock': 10,
      'capacidadMaxima': 18,
      'imagenUrl': _imagen('cubiertos'),
      'descripcion': 'Cuchara, tenedor, cuchillo y popote en estuche de tela.',
      'porcentajeDescuento': 5.0,
    },
    {
      'id': 'p10',
      'nombre': 'Detergente biodegradable 1 L',
      'categoria': 'Hogar',
      'precio': 98.0,
      'stock': 9,
      'capacidadMaxima': 20,
      'imagenUrl': _imagen('detergente'),
      'descripcion': 'Fórmula concentrada a base de plantas, sin fosfatos.',
      'porcentajeDescuento': null,
    },
    {
      'id': 'p11',
      'nombre': 'Vela de cera de soya',
      'categoria': 'Hogar',
      'precio': 135.0,
      'stock': 5,
      'capacidadMaxima': 12,
      'imagenUrl': _imagen('vela'),
      'descripcion': 'Aroma a lavanda con mecha de algodón, 40 h de duración.',
      'porcentajeDescuento': null,
    },
    {
      'id': 'p12',
      'nombre': 'Champú sólido de romero',
      'categoria': 'Cuidado personal',
      'precio': 110.0,
      'stock': 7,
      'capacidadMaxima': 15,
      'imagenUrl': _imagen('champu'),
      'descripcion': 'Equivale a 3 botellas de champú líquido, cero plástico.',
      'porcentajeDescuento': 12.0,
    },
  ];
}
