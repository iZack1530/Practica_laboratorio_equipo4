import 'package:flutter/material.dart';

/// Filtros de categoría con `Wrap`: si no caben en una línea, saltan a la
/// siguiente en lugar de provocar un RenderFlex Overflow.
class EtiquetasCategorias extends StatelessWidget {
  const EtiquetasCategorias({
    super.key,
    required this.categorias,
    required this.seleccionada,
    required this.alSeleccionar,
  });

  final List<String> categorias;
  final String? seleccionada;
  final ValueChanged<String?> alSeleccionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            avatar: const Icon(Icons.eco_outlined, size: 18),
            label: const Text('Todas'),
            selected: seleccionada == null,
            onSelected: (_) => alSeleccionar(null),
          ),
          for (final categoria in categorias)
            ChoiceChip(
              label: Text(categoria),
              selected: seleccionada == categoria,
              onSelected: (activa) => alSeleccionar(activa ? categoria : null),
            ),
        ],
      ),
    );
  }
}
