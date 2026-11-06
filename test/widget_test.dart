import 'package:ecomarket_app/presentation/app.dart';
import 'package:ecomarket_app/presentation/controllers/catalogo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/repositorios_falsos.dart';

void main() {
  testWidgets('muestra el catálogo y avisa con SnackBar cuando no hay stock suficiente', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final controller = CatalogoController(
      catalogoRepositorio: RepositorioCatalogoFalso(),
      rastreoRepositorio: RepositorioRastreoFalso(),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(EcoMarketApp(controller: controller));
    expect(find.text('Cargando catálogo ecológico…'), findsOneWidget);

    await tester.pump();
    await tester.pump();
    expect(find.text('Termo de bambú'), findsOneWidget);
    expect(find.text('Rellenar Stock'), findsOneWidget);

    // Primera unidad: se agrega correctamente.
    await tester.tap(find.text('Agregar').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(controller.cantidadEnCarrito('a'), 1);

    // Segunda unidad: el stock real es 1, debe aparecer la advertencia.
    await tester.tap(find.text('Sin stock').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Stock insuficiente'), findsOneWidget);

    // Rellenar Stock refresca la pantalla al instante.
    await tester.tap(find.text('Rellenar Stock'));
    await tester.pump();
    expect(controller.disponiblesPara('a'), 4);
    expect(find.text('Disponibles: 4'), findsOneWidget);
  });
}
