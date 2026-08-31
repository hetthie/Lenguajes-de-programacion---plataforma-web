import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF1D3FCB);
const Color kDarkText = Color(0xFF161A2B);
const Color kGreyText = Color(0xFF5C6470);
const Color kDividerColor = Color(0xFFE3E6EC);
const Color kOuterBg = Color(0xFFE9EEF6);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOuterBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TopNavBar(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 0, 48, 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 700;
                          return isWide
                              ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 6, child: _HeroText()),
                                  SizedBox(width: 32),
                                  Expanded(
                                    flex: 5,
                                    child: Image.asset(
                                      'assets/images/city_hero.PNG',
                                      width: 900,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _HeroText(),
                                  SizedBox(height: 32),
                                  _HeroImagePlaceholder(),
                                ],
                              );
                        },
                      ),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kDividerColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 28, 48, 0),
      child: Row(
        children: [
          _LogoPlaceholder(),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PORTAL DE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDarkText,
                  height: 1.05,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'DENUNCIAS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDarkText,
                  height: 1.05,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'Ciudadanas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: kGreyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    // Reemplaza este Container por: Image.asset('assets/logo.png', width: 56, height: 56)
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Image.asset('assets/images/city.png'),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Bienvenido al Portal de\nDenuncias Ciudadanas',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: kDarkText,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Haga oír su voz. Reporte incidentes y contribuya a '
          'mejorar su ciudad de manera segura y transparente.',
          style: TextStyle(fontSize: 16, color: kGreyText, height: 1.5),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            _OutlinedNavButton(
              label: 'Iniciar Sesión',
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
            const SizedBox(width: 16),
            _FilledNavButton(
              label: 'Registrarse',
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutlinedNavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _OutlinedNavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryBlue,
        side: const BorderSide(color: kPrimaryBlue, width: 1.6),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FilledNavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _FilledNavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HeroImagePlaceholder extends StatelessWidget {
  const _HeroImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    // Dimensiones aproximadas de la ilustración original: ~460 x 300
    // Reemplaza este Container por:
    // Image.asset('assets/hero_illustration.png', width: 460, height: 300, fit: BoxFit.contain)
    return AspectRatio(
      aspectRatio: 600 / 500,
      child: Image.asset(
        'assets/images/city_hero.PNG',
        width: 560,
        fit: BoxFit.contain,
      ),
    );
  }
}
