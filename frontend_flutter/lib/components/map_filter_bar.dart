import 'package:flutter/material.dart';

class MapFilterBar extends StatelessWidget {
  static const allValue = 'todos';

  final List<String> categories;
  final String selectedStatus;
  final String selectedCategory;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onRefresh;
  final bool isRefreshing;
  final int visibleCount;

  const MapFilterBar({
    super.key,
    required this.categories,
    required this.selectedStatus,
    required this.selectedCategory,
    required this.onStatusChanged,
    required this.onCategoryChanged,
    required this.onRefresh,
    required this.isRefreshing,
    required this.visibleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                value: selectedStatus,
                isDense: true,
                decoration: _decoration('Estado'),
                items: const [
                  DropdownMenuItem(value: allValue, child: Text('Todos')),
                  DropdownMenuItem(
                    value: 'pendiente',
                    child: Text('Pendientes'),
                  ),
                  DropdownMenuItem(
                    value: 'en_proceso',
                    child: Text('En proceso'),
                  ),
                  DropdownMenuItem(
                    value: 'resuelta',
                    child: Text('Resueltas'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onStatusChanged(value);
                },
              ),
            ),
            SizedBox(
              width: 230,
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                isDense: true,
                isExpanded: true,
                decoration: _decoration('Categoría'),
                items: [
                  const DropdownMenuItem(
                    value: allValue,
                    child: Text('Todas'),
                  ),
                  ...categories.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onCategoryChanged(value);
                },
              ),
            ),
            Chip(
              avatar: const Icon(Icons.location_on_outlined, size: 18),
              label: Text('$visibleCount ubicaciones'),
            ),
            IconButton(
              tooltip: 'Actualizar mapa',
              onPressed: isRefreshing ? null : onRefresh,
              icon:
                  isRefreshing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
