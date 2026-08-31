import 'package:flutter/material.dart';
import 'package:frontend_flutter/models/categoria.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../components/location_picker.dart';
import '../../providers/app_provider.dart';

const Color kScreenBg = Color(0xFFF8FAFC);
const Color kCardBorder = Color(0xFFF1F5F9);
const Color kDarkText = Color(0xFF1E293B);
const Color kGreyText = Color(0xFF64748B);
const Color kLabelColor = Color(0xFF475569);
const Color kInputBorder = Color(0xFFCBD5E1);
const Color kInputBg = Color(0xFFFAFAFA);
const Color kPrimaryBlue = Color(0xFF2563EB);
const Color kBorderColor = Color(0xFFE1E5EC);

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
  LatLng? _selectedLocation;

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
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona la ubicación exacta en el mapa.'),
        ),
      );
      return;
    }

    final provider = context.read<AppProvider>();

    final error = await provider.createComplaint(
      titulo: _titleController.text.trim(),
      descripcion: _descController.text.trim(),
      categoriaId: _categoriaId!,
      direccionReferencial: _addressController.text.trim(),
      latitud: _selectedLocation!.latitude,
      longitud: _selectedLocation!.longitude,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Denuncia publicada correctamente.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 520 ? 520.0 : double.infinity;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Form(
                    key: _formKey,
                    child: _FormCard(
                      tituloController: _titleController,
                      ubicacionController: _addressController,
                      descripcionController: _descController,
                      categoriaId: _categoriaId,
                      selectedLocation: _selectedLocation,
                      onLocationSelected:
                          (location) =>
                              setState(() => _selectedLocation = location),
                      onCategoriaChanged:
                          (val) => setState(() => _categoriaId = val),
                      categorias: provider.categorias,
                      isLoadingCategorias: provider.isLoadingCategorias,
                      onSubmit: _submit,
                      isSubmitting: provider.isSubmitting,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kDarkText, size: 18),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Nueva Denuncia',
        style: TextStyle(
          color: kDarkText,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: kBorderColor, height: 1),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController tituloController;
  final TextEditingController ubicacionController;
  final TextEditingController descripcionController;
  final int? categoriaId;
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;
  final Function(int?) onCategoriaChanged;
  final List<Categoria> categorias;
  final bool isLoadingCategorias;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  const _FormCard({
    required this.tituloController,
    required this.ubicacionController,
    required this.descripcionController,
    required this.categoriaId,
    required this.selectedLocation,
    required this.onLocationSelected,
    required this.onCategoriaChanged,
    required this.categorias,
    required this.isLoadingCategorias,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          _LabeledField(
            label: 'Título',
            controller: tituloController,
            hintText: 'Ej. Bache en la Av. Principal',
            validatorText: 'Ingresa un título',
          ),
          const SizedBox(height: 20),

          // Categoría (dropdown)
          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kLabelColor,
            ),
          ),
          const SizedBox(height: 6),
          _CategoriaDropdown(
            value: categoriaId,
            onChanged: onCategoriaChanged,
            categorias: categorias,
            isLoading: isLoadingCategorias,
          ),
          const SizedBox(height: 20),

          // Ubicación / Dirección referencial
          _LabeledField(
            label: 'Ubicación / Dirección referencial',
            controller: ubicacionController,
            hintText: 'Ej. Frente a la parada de buses del sector norte',
            validatorText: 'Ingresa una dirección',
          ),
          const SizedBox(height: 20),

          LocationPicker(
            selectedLocation: selectedLocation,
            onLocationSelected: onLocationSelected,
          ),
          const SizedBox(height: 20),

          // Descripción detallada (multilínea)
          const Text(
            'Descripción detallada',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kLabelColor,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: descripcionController,
            maxLines: 4,
            style: const TextStyle(fontSize: 14, color: kDarkText),
            decoration: InputDecoration(
              hintText: 'Explica detalladamente la situación acontecida...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: kInputBg,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kInputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kInputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: kPrimaryBlue, width: 1.4),
              ),
            ),
            validator:
                (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Ingresa una descripción'
                        : null,
          ),
          const SizedBox(height: 24),

          // Botón de acción principal
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: kPrimaryBlue.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text(
                        'Publicar Denuncia',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String validatorText;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.validatorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kLabelColor,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: kDarkText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            filled: true,
            fillColor: kInputBg,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kInputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPrimaryBlue, width: 1.4),
            ),
          ),
          validator:
              (value) =>
                  (value == null || value.trim().isEmpty)
                      ? validatorText
                      : null,
        ),
      ],
    );
  }
}

class _CategoriaDropdown extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final List<Categoria> categorias;
  final bool isLoading;

  const _CategoriaDropdown({
    required this.value,
    required this.onChanged,
    required this.categorias,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kInputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kInputBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<int>(
          value: value,
          isExpanded: true,
          icon:
              isLoading
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimaryBlue,
                    ),
                  )
                  : const Icon(
                    Icons.keyboard_arrow_down,
                    color: kGreyText,
                    size: 20,
                  ),
          hint: Text(
            isLoading ? 'Cargando categorías...' : 'Selecciona una categoría',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          ),
          style: const TextStyle(fontSize: 14, color: kDarkText),
          items:
              isLoading
                  ? []
                  : categorias
                      .map(
                        (cat) => DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.nombre),
                        ),
                      )
                      .toList(),
          onChanged: isLoading ? null : onChanged,
          validator: (value) {
            return value == null ? 'Selecciona una categoría' : null;
          },
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }
}
