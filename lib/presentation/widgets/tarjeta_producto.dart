import 'package:flutter/material.dart';

import '../../domain/entities/producto.dart';
import '../utils/formato_moneda.dart';
import 'imagen_producto.dart';

/// Tarjeta del SliverGrid. La imagen ocupa el espacio elástico (`Expanded`)
/// y la información tiene altura acotada, por lo que la tarjeta nunca
/// desborda aunque cambie el tamaño de pantalla.
class TarjetaProducto extends StatelessWidget {
  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.disponibles,
    required this.enCarrito,
    required this.alAgregar,
  });

  final Producto producto;
  final int disponibles;
  final int enCarrito;
  final VoidCallback alAgregar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;
    final sinUnidades = disponibles <= 0;
    final estiloNombre = tema.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final altoNombre =
        MediaQuery.textScalerOf(context).scale(estiloNombre?.fontSize ?? 14) * (estiloNombre?.height ?? 1.43) * 2;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImagenProducto(url: producto.imagenUrl),
                if (producto.tieneDescuento)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Etiqueta(
                      texto: '-${producto.porcentajeDescuento!.round()}%',
                      fondo: esquema.tertiary,
                      color: esquema.onTertiary,
                    ),
                  ),
                if (producto.estaAgotado)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _Etiqueta(texto: 'Agotado', fondo: esquema.error, color: esquema.onError),
                  )
                else if (producto.tieneStockBajo)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _Etiqueta(
                      texto: '¡Últimas piezas!',
                      fondo: esquema.errorContainer,
                      color: esquema.onErrorContainer,
                    ),
                  ),
                if (enCarrito > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _Etiqueta(texto: '$enCarrito en carrito', fondo: esquema.primary, color: esquema.onPrimary),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: altoNombre,
                  child: Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: estiloNombre),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        formatearMoneda(producto.precioFinal),
                        style: tema.textTheme.titleMedium?.copyWith(
                          color: esquema.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (producto.tieneDescuento) ...[
                        const SizedBox(width: 6),
                        Text(
                          formatearMoneda(producto.precio),
                          style: tema.textTheme.labelSmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: esquema.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    sinUnidades ? 'Sin unidades disponibles' : 'Disponibles: $disponibles',
                    style: tema.textTheme.labelSmall?.copyWith(
                      color: sinUnidades ? esquema.error : esquema.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 36,
                  child: FilledButton.tonalIcon(
                    onPressed: alAgregar,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor: sinUnidades ? esquema.errorContainer : null,
                      foregroundColor: sinUnidades ? esquema.onErrorContainer : null,
                    ),
                    icon: Icon(sinUnidades ? Icons.remove_shopping_cart_outlined : Icons.add_shopping_cart, size: 18),
                    label: FittedBox(fit: BoxFit.scaleDown, child: Text(sinUnidades ? 'Sin stock' : 'Agregar')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.fondo, required this.color});

  final String texto;
  final Color fondo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
