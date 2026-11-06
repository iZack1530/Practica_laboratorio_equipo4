import 'package:flutter/material.dart';

import 'data/datasources/catalogo_fuente_simulada.dart';
import 'data/datasources/gps_fuente_simulada.dart';
import 'data/repositories/catalogo_repositorio_impl.dart';
import 'data/repositories/rastreo_repositorio_impl.dart';
import 'presentation/app.dart';
import 'presentation/controllers/catalogo_controller.dart';

/// Punto de entrada y raíz de composición: aquí, y sólo aquí, se conectan
/// las implementaciones concretas de la capa de datos con la presentación.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = CatalogoController(
    catalogoRepositorio: CatalogoRepositorioImpl(CatalogoFuenteSimulada()),
    rastreoRepositorio: RastreoRepositorioImpl(GpsFuenteSimulada()),
  );

  runApp(EcoMarketApp(controller: controller));
}
