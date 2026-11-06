/// Formatea un importe en pesos mexicanos: 1234.5 → "$1,234.50".
String formatearMoneda(double valor) {
  final negativo = valor < 0;
  final centavosTotales = (valor.abs() * 100).round();
  final enteros = (centavosTotales ~/ 100).toString();
  final centavos = (centavosTotales % 100).toString().padLeft(2, '0');

  final miles = StringBuffer();
  for (var indice = 0; indice < enteros.length; indice++) {
    final restantes = enteros.length - indice;
    miles.write(enteros[indice]);
    if (restantes > 1 && restantes % 3 == 1) miles.write(',');
  }
  final signo = negativo ? '-' : '';
  return '$signo\$$miles.$centavos';
}

/// Formatea una hora como "HH:mm:ss".
String formatearHora(DateTime fecha) {
  String dosDigitos(int numero) => numero.toString().padLeft(2, '0');
  return '${dosDigitos(fecha.hour)}:${dosDigitos(fecha.minute)}:${dosDigitos(fecha.second)}';
}
