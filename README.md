# EcoMarket App — Práctica de laboratorio (Equipo 4)

Minisistema móvil de **catálogo ecológico y monitoreo satelital en tiempo real** construido en Flutter con
**Clean Architecture**, programación asíncrona (`Future` / `Stream`), control de nulabilidad y el
**patrón Observer** (`ChangeNotifier` + `ListenableBuilder`).

---

## 1. Requisitos

| Herramienta | Versión mínima |
|---|---|
| Flutter SDK | 3.24 (Dart 3.5) — probado para 3.24 → 3.3x |
| Android Studio | Ladybug o superior (incluye JDK 17/21) con un AVD (API 24+) |
| VS Code | Extensiones **Dart** y **Flutter** (se sugieren automáticamente) |

> El emulador necesita **conexión a internet** para descargar las imágenes del catálogo.

## 2. Ejecución en VS Code + emulador de Android Studio

```bash
# 1. Abrir la carpeta del proyecto en VS Code
code Practica_laboratorio_equipo4

# 2. Descargar dependencias
flutter pub get

# 3. Iniciar el emulador (o desde Android Studio > Device Manager)
flutter emulators                 # lista los AVD disponibles
flutter emulators --launch <id>

# 4. Ejecutar
flutter run
```

En VS Code también puedes seleccionar el emulador en la barra inferior y presionar **F5**
(configuración `EcoMarket (debug)` incluida en `.vscode/launch.json`).

Pruebas automatizadas y análisis estático:

```bash
flutter analyze
flutter test
```

> **Si Gradle marcara algún problema de plantilla** (por ejemplo con una versión de Flutter muy distinta),
> ejecuta `flutter create --platforms=android .` dentro del proyecto: regenera únicamente los archivos
> Android que falten **sin tocar `lib/` ni `test/`**.

## 3. Arquitectura (Clean Architecture)

```
lib/
├── main.dart                      ← Raíz de composición (inyección de dependencias)
├── domain/                        ← Reglas de negocio puras (sin Flutter)
│   ├── entities/                  ← Producto, ItemCarrito, Pedido, DatosCliente, EstadoEnvio
│   ├── errores/                   ← StockInsuficienteExcepcion, CarritoVacioExcepcion…
│   └── repositories/              ← Contratos abstractos (interfaces)
├── data/                          ← Implementaciones concretas
│   ├── datasources/               ← Futures con retardo de 1 s y Stream GPS cada 3 s
│   ├── models/                    ← ProductoModelo (mapa → entidad)
│   └── repositories/              ← CatalogoRepositorioImpl, RastreoRepositorioImpl
└── presentation/                  ← Sólo píxeles y estado de UI
    ├── controllers/               ← CatalogoController (ChangeNotifier / Observer)
    ├── views/                     ← CatalogoView, CheckoutView
    ├── widgets/                   ← Tarjeta, imagen, etiquetas Wrap, panel GPS…
    ├── validadores/               ← Regex del formulario y formateadores de entrada
    ├── tema/                      ← Tema Material 3
    └── utils/                     ← Formato de moneda y SnackBars
```

Regla de dependencias: `presentation → domain ← data`. La presentación sólo conoce las interfaces del
dominio; `main.dart` es el único archivo que conecta las implementaciones de `data/`.

## 4. Responsabilidades por rol

| Rol | Entregables en el código |
|---|---|
| **Rol 1 — Arquitectura y Datos** | Estructura `data/ domain/ presentation/`; entidad inmutable `Producto` blindada con **lista de inicialización + `assert`** (`domain/entities/producto.dart`); getters computados (`precioFinal`, `estaAgotado`, `tieneStockBajo`…) y setter computado `categoriaSeleccionada`; persistencia temporal en RAM en `CatalogoController`. |
| **Rol 2 — UI Responsiva** | `CatalogoView`: `CustomScrollView` + `SliverAppBar(pinned: true)` colapsable + `SliverGrid` bajo demanda (`SliverChildBuilderDelegate`) con `childAspectRatio: 0.65`; categorías con `Wrap`; tarjetas sin overflow (`Expanded`, `FittedBox`, texto acotado). |
| **Rol 3 — Captura y Validación** | `CheckoutView`: `Form` coordinado por `GlobalKey<FormState>`; `TextFormField` con `validator` por expresiones regulares (nombre, correo, teléfono, dirección, CP, tarjeta + Luhn, vencimiento, CVV); avisos rojos automáticos (`AutovalidateMode`); botón Material 3 deshabilitado mientras se procesa el pago. |
| **Rol 4 — Sincronización Asíncrona** | `CatalogoFuenteSimulada` (Futures de 1 s), `GpsFuenteSimulada` (Stream con pausas de 3 s que descuenta 1 min por ciclo); integración con `FutureBuilder` (carga del catálogo y pago) y `StreamBuilder` (panel de monitoreo satelital) con estados de carga y error. |

## 5. Guion de la revisión en vivo

**Simulación de pedido**
1. Al abrir, el `FutureBuilder` muestra el cargador durante 1 s y luego el catálogo.
2. Las imágenes aparecen con progreso y desvanecimiento. La *Compostera doméstica* usa una URL inválida a
   propósito para demostrar el `errorBuilder` ("Imagen no disponible").
3. Agrega productos → la barra inferior muestra el total. Pulsa **Ir a pagar**.
4. En el checkout verás subtotal, ahorro, IVA 16 %, envío ($49, gratis desde $500 de subtotal) y **total**.
5. Llena el formulario (tarjeta de prueba `4242 4242 4242 4242`, fecha futura, CVV `123`) y confirma.
6. Tras 1 s de procesamiento se descuenta el stock real, se vacía el carrito y arranca el **monitoreo
   satelital**: el reloj baja 1 minuto cada 3 s, sincronizado en el checkout y en el catálogo.

**Prueba de estrés**
1. Intenta agregar *Bolsas reutilizables* (stock 0) o una segunda unidad de *Jabón artesanal* (stock 1)
   → aparece un **SnackBar** de advertencia "Stock insuficiente…". Lo mismo ocurre con el botón **+** del
   checkout.
2. Pulsa el botón flotante **Rellenar Stock** → todo el inventario vuelve a su capacidad máxima con un
   único `notifyListeners()` y la pantalla se refresca al instante.

## 6. Subir a GitHub (repositorio privado)

Con GitHub CLI:

```bash
cd Practica_laboratorio_equipo4
git init
git add .
git commit -m "EcoMarket App: Clean Architecture, Slivers, Form y sincronización asíncrona"
git branch -M main
gh repo create Practica_laboratorio_equipo4 --private --source=. --remote=origin --push
```

Sin GitHub CLI: crea en github.com el repositorio **privado** `Practica_laboratorio_equipo4` (sin README) y:

```bash
git remote add origin https://github.com/<tu-usuario>/Practica_laboratorio_equipo4.git
git push -u origin main
```

El `.gitignore` excluye `build/`, `.dart_tool/`, `local.properties`, el wrapper binario de Gradle y
demás archivos generados; verifica con `git status` que ninguno aparezca antes del primer commit.
