import 'package:flutter/material.dart';

/// Imagen de red con cargador fluido (progreso real + aparición gradual) y
/// `errorBuilder` para URLs caídas o sin conexión.
///
/// `cacheWidth` reduce la resolución decodificada para ahorrar memoria RAM.
class ImagenProducto extends StatelessWidget {
  const ImagenProducto({super.key, required this.url, this.anchoCache = 400});

  final String url;
  final int anchoCache;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Image.network(
      url,
      fit: BoxFit.cover,
      cacheWidth: anchoCache,
      frameBuilder: (context, child, cuadro, cargadaSincronicamente) {
        if (cargadaSincronicamente) return child;
        return AnimatedOpacity(
          opacity: cuadro == null ? 0 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        final totalBytes = progreso.expectedTotalBytes;
        final avance = totalBytes == null ? null : progreso.cumulativeBytesLoaded / totalBytes;
        return ColoredBox(
          color: esquema.surfaceContainerHighest,
          child: Center(
            child: SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 2.5, value: avance)),
          ),
        );
      },
      errorBuilder: (context, error, trazaPila) => ColoredBox(
        color: esquema.surfaceContainerHighest,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_not_supported_outlined, color: esquema.onSurfaceVariant),
                  const SizedBox(height: 4),
                  Text(
                    'Imagen no disponible',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: esquema.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
