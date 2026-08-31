import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/app_provider.dart';

const Color kCardBorder = Color(0xFFE2E8F0);
const Color kTitleText = Color(0xFF0F172A);
const Color kGreyText = Color(0xFF64748B);
const Color kPrimaryBlue = Color(0xFF2563EB);

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();

  int? _selectedCategory = 1;
  LatLng _selectedLocation = const LatLng(-2.1894, -79.8891);
  
  bool _isLoading = false;
  bool _isUploadingImage = false;
  
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _uploadedImageUrl;

  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'nombre': 'Baches y Vías'},
    {'id': 2, 'nombre': 'Alumbrado Público'},
    {'id': 3, 'nombre': 'Acumulación de Basura'},
    {'id': 4, 'nombre': 'Agua Potable y Alcantarillado'},
    {'id': 5, 'nombre': 'Parques y Áreas Verdes'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.image,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _imageFileName = file.name;
      _isUploadingImage = true;
    });

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(' ', '_')}';
      final supabase = Supabase.instance.client;

      await supabase.storage.from('denuncias-fotos').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final publicUrl = supabase.storage.from('denuncias-fotos').getPublicUrl(fileName);

      setState(() {
        _uploadedImageUrl = publicUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotografía subida a Supabase Storage.')),
        );
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await context.read<AppProvider>().createComplaint(
      titulo: _titleController.text.trim(),
      descripcion: _descController.text.trim(),
      categoriaId: _selectedCategory ?? 1,
      latitud: _selectedLocation.latitude,
      longitud: _selectedLocation.longitude,
      direccionReferencial: _addressController.text.trim(),
      fotoUrl: _uploadedImageUrl,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Denuncia creada exitosamente!')),
      );
      _titleController.clear();
      _descController.clear();
      _addressController.clear();
      setState(() {
        _imageBytes = null;
        _imageFileName = null;
        _uploadedImageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Denuncia')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kCardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Registrar Denuncia Ciudadana',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kTitleText),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título de la denuncia',
                          hintText: 'Ej. Fuga de agua en Av. 9 de Octubre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa un título' : null,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría de la incidencia',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat['id'] as int,
                            child: Text(cat['nombre'].toString()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción detallada',
                          hintText: 'Explica lo que sucede con precisión...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa la descripción' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección referencial',
                          hintText: 'Ej. Junto a la farmacia principal',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'EVIDENCIA FOTOGRÁFICA',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGreyText, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: Text(_imageFileName != null ? 'Cambiar imagen: $_imageFileName' : 'Seleccionar fotografía desde tu dispositivo'),
                        onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                      ),
                      const SizedBox(height: 12),

                      if (_isUploadingImage) ...[
                        const LinearProgressIndicator(),
                        const SizedBox(height: 6),
                        const Text('Subiendo fotografía a Supabase Storage...', style: TextStyle(fontSize: 12, color: kGreyText)),
                        const SizedBox(height: 12),
                      ],

                      if (_imageBytes != null && !_isUploadingImage) ...[
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kCardBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const Text(
                        'SELECCIONA LA UBICACIÓN EN EL MAPA',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kGreyText, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kCardBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: _selectedLocation,
                            initialZoom: 13.0,
                            onTap: (tapPos, latLng) {
                              setState(() => _selectedLocation = latLng);
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.frontend_flutter',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: (_isLoading || _isUploadingImage) ? null : _submitForm,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ENVIAR DENUNCIA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
