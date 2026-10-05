import 'dart:io';
import 'package:flutter/material.dart';
import '../Home.dart';
import '../database/db_helper.dart';
import '../main.dart';
import '../models/persona.dart';
import 'agregar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Paleta de colores Hatsune Miku
  static const Color mikuTeal = Color(0xFF39C5BB);
  static const Color mikuDarkTeal = Color(0xFF1B8D85);
  static const Color mikuPink = Color(0xFFE12885);
  static const Color mikuLightBg = Color(0xFFE8F8F7);

  List<Persona> _personas = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPersonas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Carga o recarga la lista de personas desde SQLite
  Future<void> _cargarPersonas([String? query]) async {
    setState(() => _isLoading = true);
    try {
      List<Persona> lista;
      if (query != null && query.trim().isNotEmpty) {
        lista = await DatabaseHelper.instance.searchPersonas(query.trim());
      } else {
        lista = await DatabaseHelper.instance.getPersonas();
      }
      setState(() {
        _personas = lista;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// Abre la pantalla para agregar o editar un registro
  Future<void> _abrirFormulario([Persona? persona]) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AgregarScreen(personaParaEditar: persona),
      ),
    );

    // Si se guardó o actualizó un registro, recargar la lista
    if (resultado == true) {
      _cargarPersonas();
    }
  }

  /// Muestra diálogo de confirmación para eliminar un registro
  void _confirmarEliminacion(Persona persona) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: mikuPink, size: 28),
              SizedBox(width: 8),
              Text('Eliminar registro'),
            ],
          ),
          content: Text(
            '¿Está seguro de que desea eliminar a "${persona.nombre}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await DatabaseHelper.instance.deletePersona(persona.id!, persona.foto);
                  _cargarPersonas();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${persona.nombre}" eliminado correctamente'),
                        backgroundColor: mikuDarkTeal,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra modal inferior de configuración e información del proyecto
  void _mostrarConfiguracion() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = themeNotifier.value == ThemeMode.dark;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuración & Información',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Opción interactiva para alternar Modo Noche
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: mikuTeal,
                    ),
                    title: const Text('Modo Noche (Predominio Negro)'),
                    value: isDark,
                    activeThumbColor: mikuTeal,
                    onChanged: (bool valor) {
                      setModalState(() {
                        themeNotifier.value = valor ? ThemeMode.dark : ThemeMode.light;
                      });
                      setState(() {});
                    },
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.storage, color: mikuTeal),
                    title: const Text('Total de registros'),
                    trailing: Text(
                      '${_personas.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: mikuTeal),
                    title: Text('Versión de la App'),
                    subtitle: Text('1.0.0'),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mikuTeal,
                        foregroundColor: isDark ? Colors.black87 : Colors.white,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: esModoOscuro ? const Color(0xFF161720) : mikuTeal,
        foregroundColor: esModoOscuro ? mikuTeal : Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: esModoOscuro ? Colors.white60 : Colors.white70,
                  ),
                ),
                style: TextStyle(
                  color: esModoOscuro ? Colors.white : Colors.white,
                  fontSize: 18,
                ),
                onChanged: (val) => _cargarPersonas(val),
              )
            : Text(
                'Mi Primera App',
                style: TextStyle(
                  color: esModoOscuro ? mikuTeal : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          // 1. Botón para alternar directamente Modo Noche / Modo Día
          IconButton(
            icon: Icon(
              esModoOscuro ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            color: esModoOscuro ? mikuTeal : Colors.white,
            tooltip: esModoOscuro ? 'Cambiar a Modo Día' : 'Cambiar a Modo Noche',
            onPressed: () {
              themeNotifier.value = esModoOscuro ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          // 2. Botón de búsqueda
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            color: esModoOscuro ? mikuTeal : Colors.white,
            tooltip: _isSearching ? 'Cerrar búsqueda' : 'Buscar',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _cargarPersonas();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          // 3. Botón de configuración
          IconButton(
            icon: const Icon(Icons.settings),
            color: esModoOscuro ? mikuTeal : Colors.white,
            tooltip: 'Configuración',
            onPressed: _mostrarConfiguracion,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _cargarPersonas(),
        color: mikuTeal,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 1. CABECERA VISUAL (StatelessWidget desde Home.dart)
            const HomeHeader(),

            Divider(
              color: esModoOscuro ? Colors.white12 : Colors.black12,
              thickness: 1,
              indent: 24,
              endIndent: 24,
            ),
            const SizedBox(height: 8),

            // Título de sección de registros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PERSONAS REGISTRADAS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: esModoOscuro ? Colors.white60 : Colors.black54,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${_personas.length} registros',
                    style: TextStyle(
                      fontSize: 12,
                      color: esModoOscuro ? mikuTeal : mikuDarkTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 2. LISTA DINÁMICA DE PERSONAS REGISTRADAS (StatefulWidget)
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: mikuTeal),
                ),
              )
            else if (_personas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 60,
                      color: esModoOscuro ? Colors.white24 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSearching
                          ? 'No se encontraron resultados para la búsqueda'
                          : 'Aún no hay personas registradas.\nPresiona el botón "+" para registrar una nueva.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: esModoOscuro ? Colors.white60 : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _personas.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 20,
                  color: esModoOscuro ? Colors.white10 : Colors.black12,
                ),
                itemBuilder: (context, index) {
                  final persona = _personas[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    leading: Hero(
                      tag: 'foto_${persona.id}',
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: esModoOscuro ? const Color(0xFF1E202B) : mikuLightBg,
                        backgroundImage: persona.foto.isNotEmpty && File(persona.foto).existsSync()
                            ? FileImage(File(persona.foto)) as ImageProvider
                            : null,
                        child: (persona.foto.isEmpty || !File(persona.foto).existsSync())
                            ? const Icon(Icons.person, color: mikuTeal, size: 28)
                            : null,
                      ),
                    ),
                    title: Text(
                      persona.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: esModoOscuro ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Registrado: ${persona.fecha}',
                      style: TextStyle(
                        fontSize: 12,
                        color: esModoOscuro ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: esModoOscuro ? mikuTeal.withValues(alpha: 0.6) : Colors.grey,
                    ),
                    // Al tocar: Editar registro
                    onTap: () => _abrirFormulario(persona),
                    // Al mantener presionado: Confirmar eliminación
                    onLongPress: () => _confirmarEliminacion(persona),
                  );
                },
              ),
            const SizedBox(height: 80), // Espacio para no tapar con el FAB
          ],
        ),
      ),
      // BOTÓN FLOTANTE (FAB)
      floatingActionButton: FloatingActionButton(
        backgroundColor: mikuTeal,
        foregroundColor: esModoOscuro ? Colors.black87 : Colors.white,
        tooltip: 'Agregar nueva persona',
        elevation: 4,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
