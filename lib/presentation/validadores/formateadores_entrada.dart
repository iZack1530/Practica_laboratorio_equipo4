import 'package:flutter/services.dart';

/// Agrupa el número de tarjeta en bloques de 4 dígitos: "4242 4242 4242 4242".
class FormateadorTarjeta extends TextInputFormatter {
  static final RegExp _noDigitos = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue anterior, TextEditingValue nuevo) {
    final digitos = nuevo.text.replaceAll(_noDigitos, '');
    final recortado = digitos.length > 16 ? digitos.substring(0, 16) : digitos;
    final agrupado = StringBuffer();
    for (var indice = 0; indice < recortado.length; indice++) {
      if (indice > 0 && indice % 4 == 0) agrupado.write(' ');
      agrupado.write(recortado[indice]);
    }
    final texto = agrupado.toString();
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// Inserta automáticamente la diagonal en la fecha de vencimiento: "MM/AA".
class FormateadorVencimiento extends TextInputFormatter {
  static final RegExp _noDigitos = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue anterior, TextEditingValue nuevo) {
    final digitos = nuevo.text.replaceAll(_noDigitos, '');
    final recortado = digitos.length > 4 ? digitos.substring(0, 4) : digitos;
    final texto = recortado.length > 2 ? '${recortado.substring(0, 2)}/${recortado.substring(2)}' : recortado;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
