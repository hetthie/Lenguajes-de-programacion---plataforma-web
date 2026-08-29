# Estado del Frontend - Plataforma de Denuncia Pública Municipal

Este documento explica, en detalle, cómo está construido el frontend en **Flutter/Dart**, cómo se organiza su arquitectura y cómo se conectará con el backend en Laravel.

---

## 1. ¿Qué es este frontend y para qué sirve?

Es una aplicación multiplataforma, enfocada en **Web y Móvil**, desarrollada en **Flutter (Dart)**. Su objetivo es proporcionar una interfaz limpia, responsiva e intuitiva para dos tipos de usuario:

- **Ciudadanos:** pueden registrarse, explorar denuncias en lista o mapa, crear nuevos reportes con fotos/ubicación y dar seguimiento al estado de sus denuncias.
- **Personal Municipal (Admin):** acceden a un panel de control para gestionar reportes, cambiar el estado de las denuncias, ver métricas, consultar el mapa de incidencias y administrar usuarios.

---

## 2. Tecnologías y Dependencias Usadas

| Parte / Librería                       | Uso                                                                         |
| -------------------------------------- | --------------------------------------------------------------------------- |
| **Flutter / Dart**                     | Framework y lenguaje para la interfaz de usuario                            |
| **`provider`**                         | Manejo del estado global de la aplicación, como sesión y lista de denuncias |
| **`flutter_map`**** + ****`latlong2`** | Renderizado de mapas interactivos basados en OpenStreetMap                  |
| **`fl_chart`**                         | Gráficos y visualizaciones para el módulo de estadísticas del administrador |
| **`http`** *(por integrar)*            | Cliente HTTP para consumir los endpoints REST de Laravel                    |

---

## 3. Estructura de Carpetas (`lib/`)

La arquitectura de la carpeta `lib/` está dividida por responsabilidades claras para facilitar el trabajo en equipo:

```text
lib/
├── main.dart                   # Punto de entrada y configuración de rutas
├── components/                 # Componentes de UI reutilizables
│   ├── admin_layout.dart       # Shell de navegación con Sidebar para el Admin
│   ├── city_map.dart           # Componente de mapa usando FlutterMap
│   ├── nav.dart                # Barra de navegación superior del ciudadano
│   └── ui.dart                 # Insignias de estado (StatusBadge, PriorityBadge)
├── data/
│   └── mock.dart               # Datos estáticos temporales (eliminar al conectar API)
├── models/                     # Clases que representan las entidades del backend
│   ├── complaint.dart          # Modelo de Denuncia
│   └── user.dart               # Modelo de Usuario
├── pages/                      # Vistas y pantallas divididas por rol
│   ├── landing.dart            # Pantalla de bienvenida
│   ├── login.dart              # Inicio de sesión
│   ├── register.dart           # Registro de ciudadano
│   ├── citizen/                # Vistas del módulo ciudadano
│   │   ├── create_page.dart    # Formulario para publicar nueva denuncia
│   │   ├── detail_page.dart    # Detalle e historial de una denuncia
│   │   ├── list_page.dart      # Lista pública de denuncias
│   │   ├── map_page.dart       # Vista de mapa interactivo para ciudadanos
│   │   ├── my_complaints.dart  # Historial de denuncias del usuario logueado
│   │   └── profile.dart        # Perfil de usuario y cierre de sesión
│   └── admin/                  # Vistas del módulo administrativo
│       ├── complaints_admin.dart # Tabla/lista de gestión de denuncias
│       ├── dashboard.dart      # Métricas principales en tarjetas
│       ├── detail_admin.dart   # Vista para cambiar estados de la denuncia
│       ├── map_admin.dart      # Mapa de incidencias administrativo
│       ├── reports.dart        # Exportación de reportes
│       ├── stats.dart          # Gráficos y analítica
│       └── users.dart          # Lista de usuarios registrados
└── providers/
    └── app_provider.dart       # Gestor de estado que consumirá el backend
```

---

## 4. Estado Actual del Desarrollo

### 4.1 Interfaz Visual e Integración con Figma

- Se desarrolló un proyecto en **Flutter** que incorpora las funcionalidades principales necesarias para **probar y validar el funcionamiento del sistema y su interfaz de usuario**.
- Se configuró un **`ThemeData`**** global** con una paleta de colores municipal basada en **Indigo/Blue**.

### 4.2 Control de Estado y Mock Data

- Se implementó `AppProvider` utilizando la librería **`provider`**.
- Actualmente utiliza `mock.dart` para renderizar datos estáticos, también conocidos como **"datos quemados"**, de denuncias y usuarios.
- Esto permite probar la interfaz antes de realizar la conexión con el backend mediante HTTP.

### 4.3 Sistema de Roles en Frontend

La pantalla de login permite seleccionar entre:

- **Ciudadano**
- **Administrador**

Dependiendo del rol asignado en la sesión, la aplicación dirige al usuario a:

- `CitizenMainShell` → utiliza un **`BottomNavigationBar`**.
- `AdminMainShell` → utiliza un **`NavigationRail`**** responsivo**.

---

## 5. Estrategia de Conexión con el Backend (Laravel)

El backend de Laravel ya expone las respuestas en **JSON** y utiliza **Laravel Sanctum** para la autenticación mediante tokens.

A continuación, se presenta el plan técnico para conectar el frontend con el backend.

### 5.1 Deserialización de Modelos (`fromJson`)

Se deben agregar métodos `fromJson` a:

- `lib/models/complaint.dart`
- `lib/models/user.dart`

Estos métodos permitirán mapear las respuestas JSON entregadas por Laravel a los modelos utilizados por Flutter.

---

### 5.2 Módulo de Peticiones (`AppProvider`)

Se debe reemplazar la lectura de `mock.dart` por peticiones HTTP autenticadas utilizando la siguiente cabecera:

```http
Authorization: Bearer <token>
```

Las principales operaciones serán:

| Operación             | Método  | Endpoint                     | Descripción                                                                      |
| --------------------- | ------- | ---------------------------- | -------------------------------------------------------------------------------- |
| **Login**             | `POST`  | `/api/login`                 | Recibe el token enviado por Sanctum y lo almacena para las siguientes peticiones |
| **Obtener denuncias** | `GET`   | `/api/denuncias`             | Obtiene las denuncias y las convierte en objetos `Complaint`                     |
| **Crear denuncia**    | `POST`  | `/api/denuncias`             | Envía título, descripción y ubicación al backend                                 |
| **Actualizar estado** | `PATCH` | `/api/denuncias/{id}/estado` | Permite al personal municipal cambiar el estado y registrar el historial         |

### Flujo de autenticación

```text
Usuario
   │
   │ POST /api/login
   ▼
Laravel + Sanctum
   │
   │ Token
   ▼
AppProvider
   │
   │ Authorization: Bearer <token>
   ▼
Endpoints protegidos
```

---

## 6. Pendientes para el Frontend

Las principales tareas pendientes son:

- [ ] **Instalar ****`http`****:** agregar la dependencia `http: ^1.2.0` al archivo `pubspec.yaml`.
- [ ] **Reemplazar Mock Data:** conectar `AppProvider` a las URLs locales/remotas del servidor Laravel:\
  `http://127.0.0.1:8000/api`
- [ ] **Manejo de errores y estados de carga:** agregar indicadores visuales como `CircularProgressIndicator` y mensajes de error mediante `SnackBar` cuando falle una petición HTTP.
- [ ] **Subida de imágenes:** integrar la cámara/galería mediante `image_picker` en el formulario de creación de denuncias para enviar fotografías al **Supabase Storage** a través del backend.

---

## 8. Arquitectura Final Esperada

Una vez completada la integración, el flujo general de la aplicación será:

```text
                    ┌──────────────────────┐
                    │   Flutter Frontend   │
                    │      Web / Móvil     │
                    └──────────┬───────────┘
                               │
                         HTTP + Token
                               │
                               ▼
                    ┌──────────────────────┐
                    │    Laravel Backend   │
                    │    REST API + Sanctum│
                    └───────┬─────────┬────┘
                            │         │
                            ▼         ▼
                    ┌───────────┐  ┌───────────────┐
                    │ Supabase  │  │ Supabase      │
                    │ PostgreSQL│  │ Storage       │
                    └───────────┘  └───────────────┘
```

El frontend se encuentra actualmente en una etapa avanzada de desarrollo visual y estructural. La siguiente fase consiste principalmente en sustituir los datos simulados por datos reales provenientes de la API de Laravel y completar la gestión de autenticación, errores, imágenes y comunicación con Supabase.
