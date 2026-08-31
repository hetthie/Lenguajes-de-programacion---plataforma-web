import 'package:flutter/material.dart';

/// Fuente única de verdad para el estado de una denuncia.
///
/// El backend (Laravel) solo acepta y devuelve 3 valores exactos,
/// definidos en el enum de la migración `denuncias.estado`:
///   'pendiente' | 'en_proceso' | 'resuelta'
///
/// Cualquier variante que llegue desde otras fuentes (mayúsculas,
/// espacios, 'resuelto' en vez de 'resuelta', etc.) se normaliza aquí
/// antes de decidir color, ícono o texto a mostrar. Ninguna pantalla
/// debe implementar su propio switch de estado: todas usan este archivo.

/// Normaliza cualquier variante de un estado a uno de los 3 valores
/// canónicos que espera el backend.
String normalizeStatus(String raw) {
  final s = raw.toLowerCase().trim().replaceAll(' ', '_');
  if (s == 'resuelta' || s == 'resuelto') return 'resuelta';
  if (s == 'en_proceso' || s == 'en_revision' || s == 'proceso') {
    return 'en_proceso';
  }
  return 'pendiente';
}

class StatusInfo {
  final String value; // valor canónico enviado/recibido del backend
  final String label; // texto legible para mostrar en UI
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const StatusInfo({
    required this.value,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

const StatusInfo kPendiente = StatusInfo(
  value: 'pendiente',
  label: 'Pendiente',
  backgroundColor: Color(0xFFFEF3C7),
  textColor: Color(0xFFB45309),
  icon: Icons.access_time,
);

const StatusInfo kEnProceso = StatusInfo(
  value: 'en_proceso',
  label: 'En proceso',
  backgroundColor: Color(0xFFDBEAFE),
  textColor: Color(0xFF1D4ED8),
  icon: Icons.sync,
);

const StatusInfo kResuelta = StatusInfo(
  value: 'resuelta',
  label: 'Resuelta',
  backgroundColor: Color(0xFFDCFCE7),
  textColor: Color(0xFF15803D),
  icon: Icons.check_circle_outline,
);

/// Los 3 estados válidos, en orden, para construir filtros y botones
/// sin repetir valores a mano en cada pantalla.
const List<StatusInfo> kAllStatuses = [kPendiente, kEnProceso, kResuelta];

/// Devuelve la info visual (color, ícono, texto) para cualquier estado
/// crudo que venga del backend o de la UI.
StatusInfo getStatusInfo(String rawStatus) {
  switch (normalizeStatus(rawStatus)) {
    case 'resuelta':
      return kResuelta;
    case 'en_proceso':
      return kEnProceso;
    default:
      return kPendiente;
  }
}
