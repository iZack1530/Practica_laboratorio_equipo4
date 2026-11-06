import 'package:flutter/material.dart';

import '../../domain/entities/producto.dart';
import '../../domain/errores/excepciones_dominio.dart';
import '../controllers/catalogo_controller.dart';
import '../utils/avisos.dart';
import '../widgets/barra_resumen_carrito.dart';
import '../widgets/etiquetas_categorias.dart';
import '../widgets/panel_rastreo_gps.dart';
import '../widgets/tarjeta_producto.dart';
import '../view/checkout_view.dart';

/// Vista principal unificada: un solo viewport (`CustomScrollView`) que
/// combina la cabecera colapsable, filtros, rastreo GPS y la rejilla.
class CatalogoView extends StatefulWidget {
  const CatalogoView({super.key, required this.controller});

  final CatalogoController controller;

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  late Future<void> _cargaCatalogo;

  CatalogoController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    // El Future se crea una sola vez para que los redibujados no repitan la
    // petición de red simulada.
    _cargaCatalogo = _controller.cargarCatalogo();
  }

  void _reintentarCarga() {
    setState(() => _cargaCatalogo = _controller.cargarCatalogo());
  }

  void _agregarAlCarrito(Producto producto) {
    try {
      _controller.agregarAlCarrito(producto.id);
      mostrarAviso(context, '"${producto.nombre}" se agregó al carrito.', tipo: TipoAviso.exito);
    } on ExcepcionDominio catch (excepcion) {
      mostrarAviso(context, excepcion.mensaje, tipo: TipoAviso.advertencia);
    }
  }

  void _rellenarStock() {
    _controller.rellenarStock();
    mostrarAviso(context, 'Inventario reabastecido a su capacidad máxima.', tipo: TipoAviso.exito);
  }

  void _abrirCheckout() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CheckoutView(controller: _controller)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'rellenar-stock',
        onPressed: _rellenarStock,
        icon: const Icon(Icons.inventory_2_outlined),
        label: const Text('Rellenar Stock'),
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.carritoVacio) return const SizedBox.shrink();
          return BarraResumenCarrito(
            totalArticulos: _controller.totalArticulos,
            total: _controller.total,
            alPagar: _abrirCheckout,
          );
        },
      ),
      body: FutureBuilder<void>(
        future: _cargaCatalogo,
        builder: (context, instantanea) {
          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => CustomScrollView(
              slivers: [
                _CabeceraCatalogo(totalArticulos: _controller.totalArticulos, alAbrirCarrito: _abrirCheckout),
                ..._contenidoSegunEstado(instantanea),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _contenidoSegunEstado(AsyncSnapshot<void> instantanea) {
    if (instantanea.connectionState != ConnectionState.done) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Cargando catálogo ecológico…')],
            ),
          ),
        ),
      ];
    }

    if (instantanea.hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text('No se pudo cargar el catálogo.\n${instantanea.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _reintentarCarga,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final visibles = _controller.productosVisibles;
    final pedido = _controller.ultimoPedido;

    return [
      SliverToBoxAdapter(
        child: EtiquetasCategorias(
          categorias: _controller.categorias,
          seleccionada: _controller.categoriaSeleccionada,
          alSeleccionar: (categoria) => _controller.categoriaSeleccionada = categoria,
        ),
      ),
      if (pedido != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          sliver: SliverToBoxAdapter(
            child: PanelRastreoGps(
              pedidoId: pedido.id,
              flujo: _controller.flujoRastreo,
              estadoInicial: _controller.ultimoEstadoEnvio,
              alCerrar: _controller.cerrarRastreo,
            ),
          ),
        ),
      if (visibles.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('No hay productos en esta categoría.')),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate((context, indice) {
              final producto = visibles[indice];
              return TarjetaProducto(
                key: ValueKey(producto.id),
                producto: producto,
                disponibles: _controller.disponiblesPara(producto.id),
                enCarrito: _controller.cantidadEnCarrito(producto.id),
                alAgregar: () => _agregarAlCarrito(producto),
              );
            }, childCount: visibles.length),
          ),
        ),
    ];
  }
}

class _CabeceraCatalogo extends StatelessWidget {
  const _CabeceraCatalogo({required this.totalArticulos, required this.alAbrirCarrito});

  final int totalArticulos;
  final VoidCallback alAbrirCarrito;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 180,
      backgroundColor: esquema.primaryContainer,
      foregroundColor: esquema.onPrimaryContainer,
      actions: [
        IconButton(
          tooltip: 'Ver carrito',
          onPressed: alAbrirCarrito,
          icon: Badge(
            isLabelVisible: totalArticulos > 0,
            label: Text('$totalArticulos'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
        title: Text(
          'EcoMarket',
          style: TextStyle(color: esquema.onPrimaryContainer, fontWeight: FontWeight.bold),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [esquema.primaryContainer, esquema.tertiaryContainer],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                bottom: -24,
                child: Icon(Icons.eco, size: 160, color: esquema.primary.withAlpha(40)),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 52,
                child: Text(
                  'Catálogo ecológico con monitoreo satelital',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: esquema.onPrimaryContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
