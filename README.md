# 🏙️ Ciudad Resuelve

Plataforma integral multiplataforma para la gestión, geolocalización y resolución de incidencias y denuncias ciudadanas en tiempo real. 

El proyecto conecta a la ciudadanía con el personal municipal mediante una aplicación receptiva y un panel de administración centralizado.

---

## 📸 Vista Previa del Proyecto

| Módulo Ciudadano | Panel de Administración Municipal |
| :---: | :---: |
| *Feed de denuncias, mapa de calor e interfaz de reportes* | *Filtros de estado, gestión de casos e inspección geográfica* |

---

## 🛠️ Stack Tecnológico

### **Frontend (Cliente Multiplataforma)**
* **Framework:** [Flutter](https://flutter.dev/) (Soporte Web y Mobile)
* **Gestión de Estado:** `provider` (`AppProvider`)
* **Mapas & Geolocalización:** `flutter_map` + `latlong2`
* **Peticiones HTTP & Storage:** `http`, `image_picker`

### **Backend (API RESTful)**
* **Framework:** [Laravel 11](https://laravel.com/) (PHP)
* **Autenticación:** Laravel Sanctum / JWT (Bearer Tokens)
* **Seguridad:** Control de Acceso Basado en Roles (RBAC - `ciudadano` / `municipal`)

### **Base de Datos & Servicios Cloud**
* **Base de Datos Relacional:** [PostgreSQL](https://www.postgresql.org/)
* **Almacenamiento de Archivos:** [Supabase Storage](https://supabase.com/) (Bucket público para evidencias fotográficas)

---

## 📂 Estructura del Repositorio

```text
lenguajes_de_programacion/
├── backend-laravel/          # API RESTful en Laravel 11
│   ├── app/
│   │   ├── Http/Controllers/ # AuthController, DenunciaController, etc.
│   │   └── Models/          # User, Complaint, etc.
│   ├── database/             # Migraciones y Seeders
│   └── routes/api.php        # Endpoints de la API
│
├── frontend_flutter/         # App cliente en Flutter
│   ├── lib/
│   │   ├── models/           # Modelos de datos Dart
│   │   ├── pages/            # Vistas (Admin, Ciudadano, Auth)
│   │   ├── providers/        # Gestión de estado (AppProvider)
│   │   └── widgets/          # Componentes reutilizables
│   └── pubspec.yaml          # Dependencias de Flutter
│
├── setup.sh                  # Script de configuración automática (Linux/macOS)
└── README.md                 # Documentación del repositorio
