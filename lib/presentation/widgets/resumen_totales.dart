import 'package:flutter/material.dart';

import '../utils/formato_moneda.dart';

/// Desglose del importe a pagar.
class ResumenTotales extends StatelessWidget {
  const ResumenTotales({
    super.key,
    required this.subtotal,
    required this.ahorro,
    required this.impuestos,
    required this.costoEnvio,
    required this.total,
    required this.montoEnvioGratis,
  });

  final double subtotal;
  final double ahorro;
  final double impuestos;
  final double costoEnvio;
  final double total;
  final double montoEnvioGratis;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Fila(concepto: 'Subtotal', importe: formatearMoneda(subtotal)),
            if (ahorro > 0)
              _Fila(
                concepto: 'Ahorro por descuentos',
                importe: '-${formatearMoneda(ahorro)}',
                color: tema.colorScheme.tertiary,
              ),
            _Fila(concepto: 'IVA (16 %)', importe: formatearMoneda(impuestos)),
            _Fila(concepto: 'Envío', importe: costoEnvio == 0 ? 'Gratis' : formatearMoneda(costoEnvio)),
            if (costoEnvio > 0)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Envío gratis en compras desde ${formatearMoneda(montoEnvioGratis)} de subtotal.',
                  style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                ),
              ),
            const Divider(height: 24),
            _Fila(
              concepto: 'Total a pagar',
              importe: formatearMoneda(total),
              estilo: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.concepto, required this.importe, this.estilo, this.color});

  final String concepto;
  final String importe;
  final TextStyle? estilo;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final estiloBase = (estilo ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(color: color);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(concepto, style: estiloBase)),
          const SizedBox(width: 12),
          Text(importe, style: estiloBase),
        ],
      ),
    );
  }
}
