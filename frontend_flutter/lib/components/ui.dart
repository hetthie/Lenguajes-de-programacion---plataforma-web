import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      // Valores reales que manda el backend (enum de la tabla denuncias)
      case 'pendiente':
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case 'en_proceso':
        color = Colors.blue;
        label = 'En proceso';
        break;
      case 'resuelta':
        color = Colors.green;
        label = 'Resuelta';
        break;

      // Valores legacy usados por datos mock, se mantienen por compatibilidad
      case 'Atendido':
        color = Colors.green;
        label = status;
        break;
      case 'En proceso':
        color = Colors.blue;
        label = status;
        break;
      case 'En revisión':
        color = Colors.orange;
        label = status;
        break;
      case 'Rechazado':
        color = Colors.red;
        label = status;
        break;

      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color =
        priority == 'Alta'
            ? Colors.red
            : (priority == 'Media' ? Colors.orange : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
