import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/db_helper.dart';
import '../models/persona.dart';

class AgregarScreen extends StatefulWidget {
  final Persona? personaParaEditar;

  const AgregarScreen({super.key, this.personaParaEditar});

  @override
  State<AgregarScreen> createState() => _AgregarScreenState();
}

class _AgregarScreenState extends State<AgregarScreen> {
  // Paleta de colores Hatsune Miku
  static const Color mikuTeal = Color(0xFF39C5BB);
  static const Color mikuDarkTeal = Color(0xFF1B8D85);
  static const Color mikuPink = Color(0xFFE12885);
  static const Color mikuLightBg = Color(0xFFE8F8F7);

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imagenSeleccionada;
  String _rutaImagenActual = '';
  bool _isSaving = false;

  bool get _esEdicion => widget.personaParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreController.text = widget.personaParaEditar!.nombre;
      _rutaImagenActual = widget.personaParaEditar!.foto;
      if (_rutaImagenActual.isNotEmpty && File(_rutaImagenActual).existsSync()) {
        _imagenSeleccionada = File(_rutaImagenActual);
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  /// Muestra modal para seleccionar origen de la foto: Cámara o Galería
  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Wrap(
              children: [
                const ListTile(
                  title: Text(
                    'Seleccionar foto',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: mikuTeal,
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: const Text('Tomar foto con la Cámara'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _seleccionarImagen(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: mikuPink,
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: const Text('Elegir de la Galería'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _seleccionarImagen(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Toma o selecciona la imagen y la almacena temporalmente
  Future<void> _seleccionarImagen(ImageSource origen) async {
    try {
      final XFile? fotoCapturada = await _picker.pickImage(
        source: origen,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (fotoCapturada != null) {
        setState(() {
          _imagenSeleccionada = File(fotoCapturada.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar la imagen: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Guarda permanentemente la foto seleccionada en la memoria interna de la aplicación
  Future<String> _guardarFotoPermanente(File archivoTemporal) async {
    final directorioApp = await getApplicationDocumentsDirectory();
    final carpetaFotos = Directory(p.join(directorioApp.path, 'fotos_personas'));

    if (!await carpetaFotos.exists()) {
      await carpetaFotos.create(recursive: true);
    }

    final String extension = p.extension(archivoTemporal.path);
    final String nuevoNombre = 'persona_${DateTime.now().millisecondsSinceEpoch}$extension';
    final String rutaFinal = p.join(carpetaFotos.path, nuevoNombre);

    final File archivoGuardado = await archivoTemporal.copy(rutaFinal);
    return archivoGuardado.path;
  }

  /// Procesa y guarda el registro de la persona en SQLite
  Future<void> _guardarRegistro() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      String rutaFotoDefinitiva = _rutaImagenActual;

      // Si el usuario seleccionó una imagen nueva, copiarla permanentemente
      if (_imagenSeleccionada != null && _imagenSeleccionada!.path != _rutaImagenActual) {
        rutaFotoDefinitiva = await _guardarFotoPermanente(_imagenSeleccionada!);

        // Si se estaba editando y ya tenía foto previa, borrar la vieja
        if (_esEdicion && _rutaImagenActual.isNotEmpty) {
          final archivoViejo = File(_rutaImagenActual);
          if (await archivoViejo.exists()) {
            await archivoViejo.delete();
          }
        }
      }

      final nombre = _nombreController.text.trim();
      final fechaActual = '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';

      if (_esEdicion) {
        final personaActualizada = Persona(
          id: widget.personaParaEditar!.id,
          nombre: nombre,
          foto: rutaFotoDefinitiva,
          fecha: widget.personaParaEditar!.fecha,
        );
        await DatabaseHelper.instance.updatePersona(personaActualizada);
      } else {
        final nuevaPersona = Persona(
          nombre: nombre,
          foto: rutaFotoDefinitiva,
          fecha: fechaActual,
        );
        await DatabaseHelper.instance.insertPersona(nuevaPersona);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion
                  ? 'Registro actualizado exitosamente'
                  : 'Persona guardada exitosamente',
            ),
            backgroundColor: mikuDarkTeal,
          ),
        );
        Navigator.of(context).pop(true); // Retorna true para refrescar la lista
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el registro: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: esModoOscuro ? const Color(0xFF161720) : mikuTeal,
        foregroundColor: esModoOscuro ? mikuTeal : Colors.white,
        title: Text(
          _esEdicion ? 'Editar Persona' : 'Registrar Persona',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: esModoOscuro ? mikuTeal : Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vista previa de la foto con selector
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: esModoOscuro ? const Color(0xFF1E202B) : mikuLightBg,
                        border: Border.all(color: mikuTeal, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: mikuTeal.withValues(alpha: esModoOscuro ? 0.35 : 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _imagenSeleccionada != null
                            ? Image.file(
                                _imagenSeleccionada!,
                                fit: BoxFit.cover,
                                width: 150,
                                height: 150,
                              )
                            : (_rutaImagenActual.isNotEmpty && File(_rutaImagenActual).existsSync())
                                ? Image.file(
                                    File(_rutaImagenActual),
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 90,
                                    color: mikuTeal,
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _mostrarOpcionesImagen,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: mikuPink,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _mostrarOpcionesImagen,
                  icon: const Icon(Icons.add_a_photo, color: mikuTeal),
                  label: Text(
                    _imagenSeleccionada == null ? 'Elegir o tomar foto' : 'Cambiar foto',
                    style: const TextStyle(
                      color: mikuDarkTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Campo de texto: Nombre Completo
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  hintText: 'Ej. Juan Carlos Pérez Rodríguez',
                  prefixIcon: const Icon(Icons.person_outline, color: mikuTeal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: mikuTeal, width: 2),
                  ),
                  filled: true,
                  fillColor: esModoOscuro ? const Color(0xFF1C1E26) : Colors.grey.shade50,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'El nombre completo es obligatorio';
                  }
                  if (valor.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botón Guardar
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mikuTeal,
                    foregroundColor: esModoOscuro ? Colors.black87 : Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _guardarRegistro,
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _esEdicion ? 'Actualizar Registro' : 'Guardar Registro',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
