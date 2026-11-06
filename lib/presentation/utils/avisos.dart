import 'package:flutter/material.dart';

enum TipoAviso { informacion, exito, advertencia }

/// Muestra un SnackBar reemplazando al que esté visible.
void mostrarAviso(BuildContext context, String mensaje, {TipoAviso tipo = TipoAviso.informacion}) {
  final esquema = Theme.of(context).colorScheme;
  final (Color? fondo, Color texto, IconData icono) = switch (tipo) {
    TipoAviso.advertencia => (esquema.error, esquema.onError, Icons.warning_amber_rounded),
    TipoAviso.exito => (esquema.primary, esquema.onPrimary, Icons.check_circle_outline),
    TipoAviso.informacion => (null, esquema.onInverseSurface, Icons.info_outline),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: fondo,
        duration: Duration(seconds: tipo == TipoAviso.advertencia ? 4 : 2),
        content: Row(
          children: [
            Icon(icono, color: texto),
            const SizedBox(width: 12),
            Expanded(
              child: Text(mensaje, style: TextStyle(color: texto)),
            ),
          ],
        ),
      ),
    );
}
