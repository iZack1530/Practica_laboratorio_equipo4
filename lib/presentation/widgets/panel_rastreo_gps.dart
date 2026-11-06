import 'package:flutter/material.dart';

import '../../domain/entities/estado_envio.dart';
import '../utils/formato_moneda.dart';

/// Tablero de monitoreo satelital alimentado por un `StreamBuilder`.
///
/// Varias instancias pueden escuchar el mismo flujo de difusión, por lo que
/// el reloj se mantiene sincronizado en todas las pantallas.
class PanelRastreoGps extends StatelessWidget {
  const PanelRastreoGps({super.key, required this.pedidoId, required this.flujo, this.estadoInicial, this.alCerrar});

  final String pedidoId;
  final Stream<EstadoEnvio> flujo;
  final EstadoEnvio? estadoInicial;
  final VoidCallback? alCerrar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final esquema = tema.colorScheme;

    return Card(
      color: esquema.secondaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<EstadoEnvio>(
          stream: flujo,
          initialData: estadoInicial,
          builder: (context, instantanea) {
            if (instantanea.hasError) {
              return _Encabezado(
                pedidoId: pedidoId,
                icono: Icons.gps_off,
                alCerrar: alCerrar,
                detalle: 'Se perdió la señal satelital: ${instantanea.error}',
              );
            }

            final estado = instantanea.data;
            if (estado == null || estado.pedidoId != pedidoId) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Encabezado(pedidoId: pedidoId, icono: Icons.satellite_alt, alCerrar: alCerrar),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Expanded(child: Text('Conectando con el satélite…')),
                    ],
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Encabezado(
                  pedidoId: pedidoId,
                  icono: estado.entregado ? Icons.where_to_vote : Icons.satellite_alt,
                  alCerrar: alCerrar,
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    estado.entregado ? '¡Pedido entregado!' : '${estado.minutosRestantes} min para tu entrega',
                    style: tema.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: esquema.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  estado.etapa.descripcion,
                  style: tema.textTheme.bodyMedium?.copyWith(color: esquema.onSecondaryContainer),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: estado.progreso),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, valor, _) => LinearProgressIndicator(value: valor, minHeight: 8),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _Dato(icono: Icons.my_location, texto: 'Lat ${estado.latitud.toStringAsFixed(5)}'),
                    _Dato(icono: Icons.explore_outlined, texto: 'Lng ${estado.longitud.toStringAsFixed(5)}'),
                    _Dato(icono: Icons.schedule, texto: 'Actualizado ${formatearHora(estado.actualizadoEn)}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension DescripcionEtapaEnvio on EtapaEnvio {
  String get descripcion => switch (this) {
    EtapaEnvio.preparando => 'Preparando tu pedido en el centro de distribución.',
    EtapaEnvio.enCamino => 'El repartidor va en camino.',
    EtapaEnvio.cercaDeTi => 'El repartidor está muy cerca de tu domicilio.',
    EtapaEnvio.entregado => 'Gracias por comprar de forma sustentable.',
  };
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.pedidoId, required this.icono, this.alCerrar, this.detalle});

  final String pedidoId;
  final IconData icono;
  final VoidCallback? alCerrar;
  final String? detalle;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colorTexto = tema.colorScheme.onSecondaryContainer;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: colorTexto),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monitoreo satelital', style: tema.textTheme.titleMedium?.copyWith(color: colorTexto)),
              Text(
                'Pedido $pedidoId',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.labelMedium?.copyWith(color: colorTexto),
              ),
              if (detalle != null) ...[
                const SizedBox(height: 8),
                Text(detalle!, style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.error)),
              ],
            ],
          ),
        ),
        if (alCerrar != null)
          IconButton(
            tooltip: 'Ocultar rastreo',
            visualDensity: VisualDensity.compact,
            onPressed: alCerrar,
            icon: Icon(Icons.close, color: colorTexto),
          ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSecondaryContainer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: color),
        const SizedBox(width: 4),
        Text(texto, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}
