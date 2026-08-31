import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/models/municipal_report.dart';
import 'package:frontend_flutter/models/user.dart';

void main() {
  test('mantiene el rol municipal recibido desde Laravel', () {
    final user = User.fromApi({
      'id': 7,
      'name': 'Gestor Municipal',
      'email': 'municipal@example.com',
      'rol': 'municipal',
    });

    expect(user.isMunicipal, isTrue);
    expect(user.roleLabel, 'Municipal');
  });

  test('convierte el resumen y las denuncias del reporte', () {
    final report = MunicipalReport.fromJson({
      'resumen': {
        'total': 1,
        'pendientes': 1,
        'en_proceso': 0,
        'resueltas': 0,
      },
      'por_categoria': [
        {'categoria': 'Bache', 'total': 1},
      ],
      'denuncias': [
        {
          'id': 1,
          'titulo': 'Bache de prueba',
          'descripcion': 'Bache peligroso',
          'categoria': {'nombre': 'Bache'},
          'estado': 'pendiente',
          'latitud': '-2.1894',
          'longitud': '-79.8891',
          'direccion_referencial': 'Centro',
          'created_at': '2026-08-31T10:00:00Z',
        },
      ],
    });

    expect(report.total, 1);
    expect(report.byCategory.single.category, 'Bache');
    expect(report.complaints.single.latitude, -2.1894);
  });
}
