# Mi Primera App - Flutter (Edición Hatsune Miku)

Aplicación móvil desarrollada en **Flutter** para el registro de personas con foto (cámara o galería) y persistencia local en base de datos **SQLite**. Cuenta con una interfaz inspirada en la paleta de colores de **Hatsune Miku** (Turquesa `#39C5BB` y Magenta `#E12885`), respetando fielmente la estructura visual enseñada en clase.

---

## 🧩 Arquitectura de Widgets: ¿Dónde están y para qué sirven?

El proyecto combina de manera pedagógica y profesional ambos tipos de widgets fundamentales de Flutter:

### 1. `StatelessWidget` (Widgets sin estado mutable)
Son componentes puramente visuales cuyo contenido no cambia dinámicamente en tiempo de ejecución.

* **[lib/Home.dart](file:///e:/ANOTHER/mi_primera_app_flutter/mi_primera_app/lib/Home.dart)** (`HomeHeader`):
  * **Ubicación exacta**: Líneas 5 a 84.
  * **Propósito**: Renderiza la cabecera fija de la pantalla:
    1. Título en negrita `"MI PRIMERA APLICACIÓN"`.
    2. `CircleAvatar` con `radius: 100` y la imagen `assets/img/persona.avif`.
    3. `Row` centrado con los textos `"COMPUTER"` (turquesa) y `" SETIEMBRE 2026"` (gris).
  * **Por qué es Stateless**: Porque su diseño y sus textos son constantes; no dependen de ninguna variable que cambie con el uso del usuario.

* **[lib/main.dart](file:///e:/ANOTHER/mi_primera_app_flutter/mi_primera_app/lib/main.dart)** (`MiPrimeraApp`):
  * **Ubicación exacta**: Líneas 10 a 44.
  * **Propósito**: Configura el `MaterialApp`, define el tema global con la paleta de colores Hatsune Miku y establece la pantalla de inicio.

---

### 2. `StatefulWidget` (Widgets con estado dinámico)
Son componentes interactivos que manejan variables que cambian con el tiempo y redibujan la interfaz mediante `setState()`.

* **[lib/screens/home_screen.dart](file:///e:/ANOTHER/mi_primera_app_flutter/mi_primera_app/lib/screens/home_screen.dart)** (`HomeScreen`):
  * **Ubicación exacta**: Líneas 7 a 333 (clase `_HomeScreenState`).
  * **Propósito**: Controla la pantalla principal interactiva:
    1. Incrusta el `HomeHeader` (`StatelessWidget`) en la parte superior.
    2. Carga y actualiza en tiempo real la lista de personas desde SQLite (`_cargarPersonas()`).
    3. Filtra la lista dinámicamente con la barra de búsqueda en el AppBar (`_searchController`).
    4. Abre el diálogo de confirmación para eliminar registros y actualiza la vista.

* **[lib/screens/agregar_screen.dart](file:///e:/ANOTHER/mi_primera_app_flutter/mi_primera_app/lib/screens/agregar_screen.dart)** (`AgregarScreen`):
  * **Ubicación exacta**: Líneas 9 a 380 (clase `_AgregarScreenState`).
  * **Propósito**: Formulario para crear o editar personas:
    1. Permite tomar fotos con la **Cámara** o seleccionarlas de la **Galería** mediante `image_picker`.
    2. Actualiza la vista previa circular de la imagen en vivo (`_imagenSeleccionada`).
    3. Valida los campos de texto y gestiona el estado de guardado (`_isSaving`).

---

## ⚙️ ¿Cómo se Compila el Programa? ¿Se compila solo al generar el APK?

**Sí. En Flutter, compilar y generar el APK es el mismo proceso unificado.** No necesitas compilar los archivos manualmente uno por uno.

Cuando ejecutas el comando de construcción (`build`), Flutter y la herramienta de Android (**Gradle**) realizan automáticamente todos los pasos de compilación en cadena:
1. **Resolución de dependencias**: Descarga e integra las librerías de [pubspec.yaml](file:///e:/ANOTHER/mi_primera_app_flutter/mi_primera_app/pubspec.yaml) (SQLite, Image Picker, etc.).
2. **Compilación de Dart (AOT)**: Traduce tu código Dart directamente a código binario optimizado para el procesador del celular (ARM64 / ARM32).
3. **Compilación nativa de Android**: Compila el código Kotlin/Java y las bibliotecas C++ de SQLite a archivos ejecutables de Android (`.dex`).
4. **Empaquetado de recursos**: Procesa las imágenes de la carpeta `assets/img/` y el archivo de manifiesto `AndroidManifest.xml`.
5. **Generación del APK**: Ensambla todo en un único archivo comprimido e instalable con extensión `.apk`.

---

## 🛠️ Requisitos del Sistema (Lo que se necesita en la PC para compilar)

Para que cualquier computadora pueda compilar este proyecto, debe tener configurado:

1. **Flutter SDK** (versión 3.19 o superior):
   * Debe estar agregado a la variable de entorno `PATH` del sistema.
2. **Android SDK con Command-Line Tools**:
   * Instalado mediante Android Studio.
   * Con las licencias aceptadas mediante: `flutter doctor --android-licenses`.
3. **Java JDK (Java 17 o superior)**:
   * La variable de entorno `JAVA_HOME` debe apuntar a la ruta del JDK (por ejemplo, el JDK integrado en Android Studio: `C:\Program Files\Android\Android Studio\jbr`).
4. **Verificación rápida del entorno**:
   Para asegurarte de que tu PC cumple con todo, ejecuta en cualquier momento:
   ```bash
   flutter doctor
   ```
   *(Si Android toolchain y Flutter aparecen con check verde `[√]`, tu PC está lista para compilar).*

---

## 🚀 Cómo Ejecutar y Compilar la Aplicación

### Opción A: Compilar y generar el instalador APK (Para instalarlo tú mismo)
Este comando compila toda la aplicación en modo producción (**Release**) optimizado para cualquier celular Android:

1. Abre la terminal en la carpeta del proyecto y ejecuta:
   ```bash
   flutter build apk --release
   ```
2. Una vez que termine (toma entre 1 y 2 minutos), tu instalador final quedará ubicado en:
   📂 `build/app/outputs/flutter-apk/app-release.apk`
3. Pasa ese archivo a tu teléfono (por cable, WhatsApp o Drive) e instálalo.

---

### Opción B: Ejecutar directamente en tu teléfono (Depuración rápida y Hot Reload)
Si tienes el celular conectado a la PC con cable USB y no quieres generar el archivo APK final:

1. Conecta tu teléfono Android por USB con la **Depuración USB** activada.
2. Verifica que Flutter reconozca tu dispositivo:
   ```bash
   flutter devices
   ```
3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```
   *La app se compilará en modo Debug, se instalará sola en el teléfono y se abrirá en tu pantalla con recarga rápida en vivo (Hot Reload). Para detener la ejecución, pulsa la tecla `q` en la terminal.*

---

## 🧹 Cómo Limpiar el Espacio en Disco

Cuando compilas la app, Android y Gradle generan carpetas temporales (`build/` y `.dart_tool/`) que pueden llegar a ocupar cerca de 1 GB. 

Para devolver el proyecto a su tamaño liviano original (menos de 5 MB) sin borrar tu código fuente:

```bash
flutter clean
```

> [!TIP]
> Ejecuta siempre `flutter clean` después de copiar tu APK o cuando quieras compartir la carpeta por Drive, correo o GitHub.

---

## 🖼️ Cómo Cambiar la Foto Estática del Encabezado

La imagen del banner central se ubica en la carpeta:
📂 `assets/img/`

### Reglas para que la foto no se descuadre:
1. **Proporción**: Debe ser **1:1 (cuadrada)**. Si es rectangular, el círculo recortará los costados.
2. **Dimensiones recomendadas**: **500 × 500 px** o **600 × 600 px** (proporciona máxima nitidez en pantallas móviles modernas).
3. **Formato**: Puedes usar `.avif`, `.jpg` o `.png`.

### Si deseas usar otra foto o formato (por ejemplo `.jpg`):
1. Copia tu imagen en `assets/img/` (ejemplo: `assets/img/foto.jpg`).
2. Abre [lib/Home.dart](file:///e:/ANOTHER/mi_primera_app_flutter/mi_primera_app/lib/Home.dart#L52) y cambia la línea 52:
   ```dart
   backgroundImage: AssetImage('assets/img/foto.jpg'),
   ```
3. ¡Listo! Vuelve a ejecutar la app o generar el APK.
