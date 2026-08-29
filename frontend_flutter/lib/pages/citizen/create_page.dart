import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

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
  int? _categoriaId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().fetchCategorias();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría.')),
      );
      return;
    }

    final provider = context.read<AppProvider>();

    // TODO: reemplazar por un selector real de ubicación (tocar el mapa).
    // Por ahora se usa el centro de Guayaquil como valor por defecto.
    final error = await provider.createComplaint(
      titulo: _titleController.text.trim(),
      descripcion: _descController.text.trim(),
      categoriaId: _categoriaId!,
      direccionReferencial: _addressController.text.trim(),
      latitud: -2.1894,
      longitud: -79.8891,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denuncia publicada correctamente.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Denuncia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 12),

              if (provider.isLoadingCategorias)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                )
              else if (provider.errorCategorias != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.errorCategorias!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: () => provider.fetchCategorias(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<int>(
                  value: _categoriaId,
                  items: provider.categorias
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.nombre),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _categoriaId = val),
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  validator: (value) => value == null ? 'Selecciona una categoría' : null,
                ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación / Dirección referencial',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa una dirección' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Ingresa una descripción' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: provider.isSubmitting ? null : _submit,
                child: provider.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publicar Denuncia'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
