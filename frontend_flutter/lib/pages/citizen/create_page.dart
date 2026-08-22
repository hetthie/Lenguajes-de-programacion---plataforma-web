import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/complaint.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  String _category = 'Vías y Tránsito';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Denuncia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            DropdownButtonFormField<String>(
              value: _category,
              items:
                  [
                        'Vías y Tránsito',
                        'Alumbrado',
                        'Aseo Urbano',
                        'Parques',
                        'Seguridad',
                      ]
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _category = val!),
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Ubicación / Dirección',
              ),
            ),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción detallada',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final user = context.read<AppProvider>().currentUser;
                final newComplaint = Complaint(
                  id: 'DEN-${DateTime.now().millisecondsSinceEpoch}',
                  title: _titleController.text,
                  description: _descController.text,
                  category: _category,
                  status: 'Pendiente',
                  priority: 'Media',
                  address: _addressController.text,
                  latitude: -2.1894,
                  longitude: -79.8891,
                  citizenName: user?.name ?? 'Anónimo',
                  citizenEmail: user?.email ?? 'anon@mail.com',
                  createdAt: DateTime.now(),
                  history: ['Denuncia creada'],
                );
                context.read<AppProvider>().addComplaint(newComplaint);
                Navigator.pop(context);
              },
              child: const Text('Publicar Denuncia'),
            ),
          ],
        ),
      ),
    );
  }
}
