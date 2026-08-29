import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';

const Color kPrimaryDark = Color(0xFF1B2A56);
const Color kAccentTeal = Color(0xFF17A398);
const Color kBorderColor = Color(0xFFE1E5EC);
const Color kScreenBg = Color(0xFFF8FAFC);
const Color kCardBorder = Color(0xFFF1F5F9);
const Color kDarkText = Color(0xFF1E293B);
const Color kGreyText = Color(0xFF64748B);
const Color kLabelColor = Color(0xFF475569);
const Color kInputBorder = Color(0xFFCBD5E1);
const Color kPrimaryBlue = Color(0xFF2563EB);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos.')),
      );
      return;
    }

    if (password.length < 8 || password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas deben coincidir y tener 8 caracteres.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().register(
        name: name,
        email: email,
        password: password,
      );
      final user = User.fromApi(result['user'] as Map<String, dynamic>);
      final token = result['token'] as String;

      if (!mounted) return;
      context.read<AppProvider>().setSession(user, token);
      Navigator.pushReplacementNamed(context, '/citizen');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al registrarse: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 480 ? 440.0 : double.infinity;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _LogoHeader(),
                      const SizedBox(height: 28),
                      const Text(
                        'Crea una cuenta para realizar y dar seguimiento a tus denuncias.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: kGreyText),
                      ),
                      const SizedBox(height: 28),

                      //Nombre Completo
                      const _FieldLabel('Nombre completo'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _nameController,
                        hintText: 'Ej. Juan Pérez',
                        prefixIcon: Icons.person,
                      ),

                      //Correo electronico
                      const SizedBox(height: 16),
                      const _FieldLabel('Correo Electrónico'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _emailController,
                        hintText: 'ejemplo@correo.com',
                        prefixIcon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // Contraseña
                      const SizedBox(height: 16),
                      const _FieldLabel('Contraseña'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _passwordController,
                        hintText: '••••••••••',
                        prefixIcon: Icons.lock_open_outlined,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: kGreyText,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),

                      // Confirmar Contraseña
                      const SizedBox(height: 16),
                      const _FieldLabel('Contraseña'),
                      const SizedBox(height: 8),
                      _RoundedTextField(
                        controller: _confirmPasswordController,
                        hintText: '••••••••••',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: kGreyText,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Crear cuenta',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ],
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
        'Registro de Ciudadano',
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

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LogoPlaceholder(),
        const SizedBox(width: 10),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
            children: [
              TextSpan(text: 'Ciudad\n', style: TextStyle(color: kPrimaryDark)),
              TextSpan(text: 'Resuelve', style: TextStyle(color: kAccentTeal)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Reemplaza este widget por: Image.asset('assets/logo.png', width: 48, height: 48)
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Icon(
            Icons.location_city,
            size: 44,
            color: kPrimaryDark.withOpacity(0.85),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check_circle, size: 20, color: kPrimaryDark),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kDarkText,
      ),
    );
  }
}

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _RoundedTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: kDarkText),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: kGreyText, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: kGreyText, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: kInputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: kInputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: kPrimaryBlue, width: 1.4),
        ),
      ),
    );
  }
}
