import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/datos_cliente.dart';
import '../../domain/entities/item_carrito.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/errores/excepciones_dominio.dart';
import '../controllers/catalogo_controller.dart';
import '../utils/avisos.dart';
import '../utils/formato_moneda.dart';
import '../validadores/formateadores_entrada.dart';
import '../validadores/validadores_checkout.dart';
import '../widgets/imagen_producto.dart';
import '../widgets/panel_rastreo_gps.dart';
import '../widgets/resumen_totales.dart';

/// Vista de checkout: revisión del carrito, formulario validado y pago.
///
/// Todos los campos se coordinan con una única `GlobalKey<FormState>`:
/// `validate()` dispara las validaciones en cascada y `save()` recolecta los
/// valores sin inspeccionar controladores de texto campo por campo.
class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key, required this.controller});

  final CatalogoController controller;

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final GlobalKey<FormState> _claveFormulario = GlobalKey<FormState>();
  AutovalidateMode _modoValidacion = AutovalidateMode.onUserInteraction;

  Future<Pedido>? _pagoEnCurso;
  Pedido? _pedidoConfirmado;

  String _nombre = '';
  String _correo = '';
  String _telefono = '';
  String _direccion = '';
  String _codigoPostal = '';
  String _tarjeta = '';

  CatalogoController get _controller => widget.controller;

  void _incrementar(ItemCarrito item) {
    try {
      _controller.agregarAlCarrito(item.producto.id);
    } on ExcepcionDominio catch (excepcion) {
      mostrarAviso(context, excepcion.mensaje, tipo: TipoAviso.advertencia);
    }
  }

  Future<void> _confirmarPago() async {
    final formulario = _claveFormulario.currentState;
    if (formulario == null) return;

    if (!formulario.validate()) {
      setState(() => _modoValidacion = AutovalidateMode.always);
      mostrarAviso(context, 'Revisa los campos marcados en rojo.', tipo: TipoAviso.advertencia);
      return;
    }
    formulario.save();
    FocusScope.of(context).unfocus();

    final cliente = DatosCliente(
      nombreCompleto: _nombre,
      correo: _correo,
      telefono: _telefono,
      direccion: _direccion,
      codigoPostal: _codigoPostal,
      terminacionTarjeta: _tarjeta.substring(_tarjeta.length - 4),
    );

    final pago = _controller.confirmarPago(cliente);
    setState(() => _pagoEnCurso = pago);

    try {
      final pedido = await pago;
      if (!mounted) return;
      setState(() => _pedidoConfirmado = pedido);
      mostrarAviso(context, 'Pago aprobado. ¡Gracias por tu compra!', tipo: TipoAviso.exito);
    } on ExcepcionDominio catch (excepcion) {
      if (!mounted) return;
      setState(() => _pagoEnCurso = null);
      mostrarAviso(context, excepcion.mensaje, tipo: TipoAviso.advertencia);
    } catch (error) {
      if (!mounted) return;
      setState(() => _pagoEnCurso = null);
      mostrarAviso(context, 'El pago no pudo procesarse: $error', tipo: TipoAviso.advertencia);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = _pedidoConfirmado;
    return Scaffold(
      appBar: AppBar(title: Text(pedido == null ? 'Checkout' : 'Pedido confirmado')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (pedido != null) {
              return _VistaPedidoConfirmado(pedido: pedido, controller: _controller);
            }
            if (_controller.carritoVacio && _pagoEnCurso == null) {
              return const _CarritoVacio();
            }
            return _contenidoCheckout(context);
          },
        ),
      ),
    );
  }

  Widget _contenidoCheckout(BuildContext context) {
    final tema = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: FutureBuilder<Pedido>(
          future: _pagoEnCurso,
          builder: (context, instantanea) {
            final procesando = instantanea.connectionState == ConnectionState.waiting;
            // SingleChildScrollView mantiene montado todo el formulario: un
            // ListView perezoso destruiría los campos al salir de pantalla.
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Tu carrito', style: tema.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  for (final item in _controller.itemsCarrito)
                    _FilaItemCarrito(
                      key: ValueKey(item.producto.id),
                      item: item,
                      habilitada: !procesando,
                      alIncrementar: () => _incrementar(item),
                      alDisminuir: () => _controller.disminuirDelCarrito(item.producto.id),
                      alEliminar: () => _controller.eliminarDelCarrito(item.producto.id),
                    ),
                  const SizedBox(height: 12),
                  ResumenTotales(
                    subtotal: _controller.subtotal,
                    ahorro: _controller.ahorroTotal,
                    impuestos: _controller.impuestos,
                    costoEnvio: _controller.costoEnvio,
                    total: _controller.total,
                    montoEnvioGratis: CatalogoController.montoEnvioGratis,
                  ),
                  const SizedBox(height: 24),
                  Text('Datos de envío y pago', style: tema.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _formulario(habilitado: !procesando),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: (procesando || _controller.carritoVacio) ? null : _confirmarPago,
                      icon: procesando
                          ? SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: tema.colorScheme.onSurface.withAlpha(97),
                              ),
                            )
                          : const Icon(Icons.lock_outline),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          procesando ? 'Procesando pago…' : 'Confirmar pago · ${formatearMoneda(_controller.total)}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tarjeta de prueba: 4242 4242 4242 4242 · cualquier fecha futura · CVV 123',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.labelSmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _formulario({required bool habilitado}) {
    const separacion = SizedBox(height: 14);
    return Form(
      key: _claveFormulario,
      autovalidateMode: _modoValidacion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            enabled: habilitado,
            initialValue: _nombre,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              hintText: 'Ej. Ana López García',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: ValidadoresCheckout.nombre,
            onSaved: (valor) => _nombre = (valor ?? '').trim(),
          ),
          separacion,
          TextFormField(
            enabled: habilitado,
            initialValue: _correo,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'nombre@dominio.com',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: ValidadoresCheckout.correo,
            onSaved: (valor) => _correo = (valor ?? '').trim(),
          ),
          separacion,
          TextFormField(
            enabled: habilitado,
            initialValue: _telefono,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            decoration: const InputDecoration(
              labelText: 'Teléfono (10 dígitos)',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: ValidadoresCheckout.telefono,
            onSaved: (valor) => _telefono = (valor ?? '').trim(),
          ),
          separacion,
          TextFormField(
            enabled: habilitado,
            initialValue: _direccion,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Dirección de entrega',
              hintText: 'Calle, número y colonia',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: ValidadoresCheckout.direccion,
            onSaved: (valor) => _direccion = (valor ?? '').trim(),
          ),
          separacion,
          TextFormField(
            enabled: habilitado,
            initialValue: _codigoPostal,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
            decoration: const InputDecoration(
              labelText: 'Código postal',
              prefixIcon: Icon(Icons.markunread_mailbox_outlined),
            ),
            validator: ValidadoresCheckout.codigoPostal,
            onSaved: (valor) => _codigoPostal = (valor ?? '').trim(),
          ),
          separacion,
          TextFormField(
            enabled: habilitado,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FormateadorTarjeta()],
            decoration: const InputDecoration(
              labelText: 'Número de tarjeta',
              hintText: '0000 0000 0000 0000',
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: ValidadoresCheckout.tarjeta,
            onSaved: (valor) => _tarjeta = ValidadoresCheckout.soloDigitos(valor),
          ),
          separacion,
          Wrap(
            spacing: 12,
            runSpacing: 14,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  enabled: habilitado,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FormateadorVencimiento()],
                  decoration: const InputDecoration(
                    labelText: 'Vencimiento',
                    hintText: 'MM/AA',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  validator: ValidadoresCheckout.vencimiento,
                ),
              ),
              SizedBox(
                width: 160,
                child: TextFormField(
                  enabled: habilitado,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: const InputDecoration(labelText: 'CVV', prefixIcon: Icon(Icons.password)),
                  validator: ValidadoresCheckout.cvv,
                  onFieldSubmitted: (_) => _confirmarPago(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilaItemCarrito extends StatelessWidget {
  const _FilaItemCarrito({
    super.key,
    required this.item,
    required this.habilitada,
    required this.alIncrementar,
    required this.alDisminuir,
    required this.alEliminar,
  });

  final ItemCarrito item;
  final bool habilitada;
  final VoidCallback alIncrementar;
  final VoidCallback alDisminuir;
  final VoidCallback alEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final producto = item.producto;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(dimension: 56, child: ImagenProducto(url: producto.imagenUrl, anchoCache: 160)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre, maxLines: 2, overflow: TextOverflow.ellipsis, style: tema.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    '${formatearMoneda(producto.precioFinal)} c/u · Stock: ${producto.stock}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.textTheme.labelSmall,
                  ),
                  Text(
                    formatearMoneda(item.subtotal),
                    style: tema.textTheme.titleSmall?.copyWith(
                      color: tema.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: item.cantidad == 1 ? 'Quitar del carrito' : 'Disminuir',
              visualDensity: VisualDensity.compact,
              onPressed: habilitada ? alDisminuir : null,
              icon: Icon(item.cantidad == 1 ? Icons.delete_outline : Icons.remove),
            ),
            Text('${item.cantidad}', style: tema.textTheme.titleMedium),
            IconButton(
              tooltip: 'Aumentar',
              visualDensity: VisualDensity.compact,
              onPressed: habilitada ? alIncrementar : null,
              icon: const Icon(Icons.add),
            ),
            IconButton(
              tooltip: 'Eliminar',
              visualDensity: VisualDensity.compact,
              onPressed: habilitada ? alEliminar : null,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  const _CarritoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            const Text('Tu carrito está vacío.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: () => Navigator.of(context).pop(), child: const Text('Volver al catálogo')),
          ],
        ),
      ),
    );
  }
}

class _VistaPedidoConfirmado extends StatelessWidget {
  const _VistaPedidoConfirmado({required this.pedido, required this.controller});

  final Pedido pedido;
  final CatalogoController controller;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final rastreando = controller.ultimoPedido?.id == pedido.id;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(Icons.check_circle, size: 72, color: tema.colorScheme.primary),
            const SizedBox(height: 12),
            Text('¡Pago confirmado!', textAlign: TextAlign.center, style: tema.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Pedido ${pedido.id} · ${pedido.totalArticulos} artículos · ${formatearMoneda(pedido.total)}',
              textAlign: TextAlign.center,
            ),
            Text(
              'Tarjeta terminación ${pedido.cliente.terminacionTarjeta}',
              textAlign: TextAlign.center,
              style: tema.textTheme.labelMedium,
            ),
            const SizedBox(height: 20),
            if (rastreando)
              PanelRastreoGps(
                pedidoId: pedido.id,
                flujo: controller.flujoRastreo,
                estadoInicial: controller.ultimoEstadoEnvio,
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Volver al catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
