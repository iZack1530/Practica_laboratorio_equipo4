/// Reglas de validación del formulario de checkout basadas en expresiones
/// regulares. Cada método respeta la firma `FormFieldValidator<String>`:
/// devuelve `null` si el valor es válido o el mensaje de error a mostrar.
abstract final class ValidadoresCheckout {
  static const String _letras = 'A-Za-zÁÉÍÓÚÜÑáéíóúüñ';

  static final RegExp _nombre = RegExp('^[$_letras]+(?:[ \'-][$_letras]+)+\$');
  static final RegExp _correo = RegExp(r'^[\w.+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$');
  static final RegExp _telefono = RegExp(r'^\d{10}$');
  static final RegExp _direccion = RegExp('^(?=.*\\d)[${_letras}0-9#.,\\- ]{8,}\$');
  static final RegExp _codigoPostal = RegExp(r'^\d{5}$');
  static final RegExp _tarjeta = RegExp(r'^\d{16}$');
  static final RegExp _vencimiento = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$');
  static final RegExp _cvv = RegExp(r'^\d{3,4}$');
  static final RegExp _espacios = RegExp(r'\s+');

  static String? nombre(String? valor) {
    final texto = (valor ?? '').trim().replaceAll(_espacios, ' ');
    if (texto.isEmpty) return 'El nombre es obligatorio.';
    if (!_nombre.hasMatch(texto)) return 'Escribe nombre y apellido usando solo letras.';
    return null;
  }

  static String? correo(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El correo es obligatorio.';
    if (!_correo.hasMatch(texto)) return 'Formato de correo inválido (ej. nombre@dominio.com).';
    return null;
  }

  static String? telefono(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El teléfono es obligatorio.';
    if (!_telefono.hasMatch(texto)) return 'El teléfono debe tener exactamente 10 dígitos.';
    return null;
  }

  static String? direccion(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'La dirección es obligatoria.';
    if (!_direccion.hasMatch(texto)) return 'Incluye calle y número (mínimo 8 caracteres).';
    return null;
  }

  static String? codigoPostal(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El código postal es obligatorio.';
    if (!_codigoPostal.hasMatch(texto)) return 'El código postal debe tener 5 dígitos.';
    return null;
  }

  static String? tarjeta(String? valor) {
    final digitos = soloDigitos(valor);
    if (digitos.isEmpty) return 'El número de tarjeta es obligatorio.';
    if (!_tarjeta.hasMatch(digitos)) return 'La tarjeta debe tener 16 dígitos.';
    if (!pasaLuhn(digitos)) return 'Número de tarjeta inválido.';
    return null;
  }

  static String? vencimiento(String? valor, {DateTime? ahora}) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'La fecha de vencimiento es obligatoria.';
    final coincidencia = _vencimiento.firstMatch(texto);
    if (coincidencia == null) return 'Usa el formato MM/AA.';
    final mes = int.parse(coincidencia.group(1)!);
    final anio = 2000 + int.parse(coincidencia.group(2)!);
    final primerDiaSiguienteMes = DateTime(anio, mes + 1);
    if (!primerDiaSiguienteMes.isAfter(ahora ?? DateTime.now())) return 'La tarjeta está vencida.';
    return null;
  }

  static String? cvv(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'El CVV es obligatorio.';
    if (!_cvv.hasMatch(texto)) return 'El CVV debe tener 3 o 4 dígitos.';
    return null;
  }

  static String soloDigitos(String? valor) => (valor ?? '').replaceAll(RegExp(r'\D'), '');

  /// Algoritmo de Luhn para detectar números de tarjeta mal capturados.
  static bool pasaLuhn(String digitos) {
    var suma = 0;
    var duplicar = false;
    for (var indice = digitos.length - 1; indice >= 0; indice--) {
      var digito = int.parse(digitos[indice]);
      if (duplicar) {
        digito *= 2;
        if (digito > 9) digito -= 9;
      }
      suma += digito;
      duplicar = !duplicar;
    }
    return suma % 10 == 0;
  }
}
