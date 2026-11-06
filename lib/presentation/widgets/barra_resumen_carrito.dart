import 'package:flutter/material.dart';

import '../utils/formato_moneda.dart';

/// Barra inferior con el resumen del carrito y acceso directo al checkout.
class BarraResumenCarrito extends StatelessWidget {
  const BarraResumenCarrito({super.key, required this.totalArticulos, required this.total, required this.alPagar});

  final int totalArticulos;
  final double total;
  final VoidCallback alPagar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Material(
      color: tema.colorScheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalArticulos == 1 ? '1 artículo' : '$totalArticulos artículos',
                      style: tema.textTheme.labelMedium,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Total ${formatearMoneda(total)}',
                        style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: alPagar,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Ir a pagar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
