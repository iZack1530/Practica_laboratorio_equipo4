import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/catalogo_controller.dart';
import 'tema/tema_ecomarket.dart';
import 'views/catalogo_view.dart';

/// Raíz visual de la aplicación.
class EcoMarketApp extends StatelessWidget {
  const EcoMarketApp({super.key, required this.controller});

  final CatalogoController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoMarket',
      debugShowCheckedModeBanner: false,
      theme: TemaEcoMarket.claro,
      darkTheme: TemaEcoMarket.oscuro,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Se acota el escalado de texto del sistema para que la geometría de
      // las tarjetas nunca colapse con fuentes de accesibilidad extremas.
      builder: (context, child) {
        final consulta = MediaQuery.of(context);
        return MediaQuery(
          data: consulta.copyWith(textScaler: consulta.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.25)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: CatalogoView(controller: controller),
    );
  }
}
