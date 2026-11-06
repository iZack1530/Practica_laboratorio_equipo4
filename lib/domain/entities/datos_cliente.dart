/// Datos de envío y pago capturados en el checkout.
///
/// Por seguridad sólo se conserva la terminación de la tarjeta, nunca el
/// número completo ni el código de seguridad.
class DatosCliente {
  const DatosCliente({
    required this.nombreCompleto,
    required this.correo,
    required this.telefono,
    required this.direccion,
    required this.codigoPostal,
    required this.terminacionTarjeta,
  }) : assert(terminacionTarjeta.length == 4, 'La terminación de la tarjeta debe tener 4 dígitos.');

  final String nombreCompleto;
  final String correo;
  final String telefono;
  final String direccion;
  final String codigoPostal;
  final String terminacionTarjeta;
}
