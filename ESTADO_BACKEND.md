# Estado del Backend - Plataforma de Denuncia Pública Municipal

Este documento explica, en detalle, todo lo que se ha hecho hasta ahora en el backend del proyecto, cómo está organizado, y qué falta por hacer. Está pensado para que cualquier integrante del equipo pueda retomarlo sin depender de que alguien más se lo explique en persona.

---

## 1. ¿Qué es este backend y para qué sirve?

Es una **API REST** construida con **Laravel (PHP)**. No tiene interfaz visual — no es una página web que se pueda abrir en el navegador y ver bonita. Su única función es **recibir peticiones** (por ejemplo, "crea esta denuncia", "dame la lista de denuncias", "inicia sesión con este correo") y **responder con datos en formato JSON**.

El frontend, que se construirá en **Flutter Web**, es quien va a "hablar" con este backend: le pide datos, el backend los busca en la base de datos y se los devuelve.

```
Flutter Web (lo que ve el usuario)
        ↓  pide datos
   Backend Laravel (este proyecto)
        ↓  guarda/consulta datos
PostgreSQL en Supabase (la base de datos)
```

---

## 2. Tecnologías usadas

| Parte | Tecnología |
|---|---|
| Framework backend | Laravel 13 (PHP) |
| Base de datos | PostgreSQL, alojada en Supabase |
| Autenticación | Laravel Sanctum (login por token) |
| Almacenamiento de fotos (pendiente de conectar) | Supabase Storage |

**Supabase** es un servicio externo (como un "PostgreSQL en la nube" con extras). No es un framework ni reemplaza a Laravel — es solamente donde vive físicamente la base de datos, para no tener que instalar PostgreSQL en la computadora de cada integrante del equipo.

---

## 3. ¿Dónde está todo esto guardado?

El proyecto vive dentro del repositorio de GitHub del equipo, en la carpeta:

```
backend-laravel/
```

Para trabajar en él, cualquier integrante debe:

```bash
git clone git@github.com:hetthie/Lenguajes-de-programacion---plataforma-web.git
cd Lenguajes-de-programacion---plataforma-web/backend-laravel
composer install
```

Luego necesita pedirle a Andie (o a quien tenga las credenciales) el archivo `.env` con los datos de conexión a Supabase, ya que **ese archivo no se sube a GitHub** por seguridad (contiene contraseñas). Sin ese archivo, el proyecto no va a poder conectarse a la base de datos.

---

## 4. ¿Qué se ha construido hasta ahora?

### 4.1 Conexión a la base de datos

El proyecto ya está conectado exitosamente a una base de datos PostgreSQL real alojada en Supabase. Esto se probó corriendo migraciones y sí funcionó.

### 4.2 Las tablas de la base de datos (migraciones)

Se crearon las siguientes tablas, además de las que Laravel trae por defecto (`users`, `sessions`, etc.):

**`categorias`** — guarda los tipos de problema que se pueden reportar (bache, alumbrado dañado, basura, etc.). Ya tiene datos precargados (ver punto 4.4).

**`denuncias`** — la tabla principal. Guarda cada denuncia con su título, descripción, categoría, quién la creó, ubicación (latitud/longitud), la URL de la foto (todavía no se sube ninguna foto real, pero el campo ya existe) y su estado actual (`pendiente`, `en_proceso`, `resuelta`).

**`historial_estados`** — cada vez que una denuncia cambia de estado, se guarda un registro aquí (quién lo cambió, de qué estado a qué estado, cuándo). Esto sirve para mostrarle al ciudadano una especie de "línea de tiempo" de su denuncia.

**`users`** (modificada) — a la tabla de usuarios que Laravel trae por defecto, se le agregó un campo `rol`, que puede ser `ciudadano` o `municipal`. Este campo decide qué puede hacer cada usuario (por ejemplo, solo alguien con rol `municipal` podrá cambiar el estado de una denuncia).

**`personal_access_tokens`** — tabla que usa Sanctum internamente para guardar los tokens de sesión de cada usuario logueado. No se toca manualmente, Laravel la maneja solo.

### 4.3 Modelos (la representación de las tablas en código)

Por cada tabla propia del proyecto, existe un "Modelo" en PHP que permite consultarla y modificarla sin escribir SQL a mano:

- `app/Models/Categoria.php`
- `app/Models/Denuncia.php`
- `app/Models/HistorialEstado.php`
- `app/Models/User.php` (el que trae Laravel, pero ya editado con el campo `rol` y las relaciones)

Estos modelos ya tienen definidas sus **relaciones** entre sí. Por ejemplo, el modelo `Denuncia` sabe que pertenece a una `Categoria` y a un `User`, y que tiene muchos `HistorialEstado`. Esto permite hacer cosas como `$denuncia->categoria->nombre` directo en el código, sin escribir consultas SQL manuales.

### 4.4 Datos de prueba precargados (seeder)

Existe un archivo (`database/seeders/CategoriaSeeder.php`) que, al ejecutarse, llena la tabla `categorias` con 8 categorías ya definidas: Bache, Alumbrado público dañado, Acumulación de basura, Daño en espacio público, Semáforo dañado, Señalización vial dañada, Fuga de agua, Otro.

Ya se ejecutó una vez y esos datos ya existen en la base de datos real de Supabase. Si alguien clona el proyecto desde cero en su computadora, solo necesita correr:

```bash
php artisan db:seed
```

(usa `firstOrCreate`, así que si se corre más de una vez, no duplica las categorías).

### 4.5 Autenticación (login/registro) — YA FUNCIONA COMPLETO Y PROBADO

Se construyó el sistema completo de autenticación usando **Laravel Sanctum** (autenticación por token, pensada específicamente para que la consuma una app externa como Flutter, no una página web tradicional).

Archivo principal: `app/Http/Controllers/Api/AuthController.php`

Tiene 3 funciones, y **las 3 ya fueron probadas manualmente con `curl` y funcionan correctamente:**

- **Registro** (`POST /api/register`): crea un usuario nuevo. Pide nombre, correo, contraseña (y su confirmación), y opcionalmente el rol (si no se manda, queda como `ciudadano` por defecto). Devuelve un token.
- **Login** (`POST /api/login`): recibe correo y contraseña, verifica que sean correctos, y devuelve un token nuevo.
- **Logout** (`POST /api/logout`): cierra la sesión del usuario (borra su token actual). Requiere mandar el token en la petición para funcionar.

**¿Cómo funciona el token en la práctica?** Cuando un usuario hace login, el backend le devuelve un texto largo (el token). Desde ese momento, cada vez que Flutter quiera pedir algo que requiera estar logueado (por ejemplo, crear una denuncia), tiene que mandar ese token en la petición, en un header llamado `Authorization`, así: `Bearer <token>`. El backend revisa ese token para saber quién es el usuario y si tiene permiso para hacer esa acción.

### 4.6 Middleware de roles

Se creó un mecanismo (`app/Http/Middleware/CheckRole.php`) que permite proteger ciertas rutas para que **solo usuarios con un rol específico** puedan usarlas. Por ejemplo, más adelante se usará para que la ruta de "cambiar estado de una denuncia" solo la puedan usar usuarios con rol `municipal`, y si un `ciudadano` intenta usarla, reciba un error de "no tienes permiso".

Ya está registrado en el sistema con el alias `rol`, listo para usarse en las rutas (ejemplo: `middleware('rol:municipal')`).

### 4.7 Validaciones (Request classes)

Se crearon dos archivos que se encargan de **validar los datos antes de que lleguen al controlador**, para no aceptar información incorrecta o incompleta:

- `app/Http/Requests/StoreDenunciaRequest.php` — valida los datos al crear una denuncia (título obligatorio, categoría que exista de verdad, coordenadas válidas, foto que sea imagen y no pese más de 5MB, etc.).
- `app/Http/Requests/UpdateEstadoRequest.php` — valida los datos al cambiar el estado de una denuncia (que el estado sea uno de los 3 permitidos, comentario opcional).

Estas dos clases **todavía no están conectadas a ningún controlador** — se crearon y definieron, pero falta construir los controladores que las usen (siguiente paso pendiente).

---

## 5. ¿Cómo se ha estado probando que todo funcione?

No se ha usado Postman ni Insomnia — se ha probado todo con `curl` directo desde la terminal, en dos pasos:

1. En una terminal, se deja corriendo el servidor local:
   ```bash
   php artisan serve
   ```
2. En **otra terminal distinta** (el servidor ocupa la primera y no se puede escribir ahí), se mandan peticiones de prueba, por ejemplo:
   ```bash
   curl -X POST http://127.0.0.1:8000/api/login \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d '{"email":"correo@ejemplo.com","password":"password123"}'
   ```

Esto es importante saberlo porque, si alguien del equipo continúa el trabajo, va a necesitar repetir este mismo patrón para probar los nuevos endpoints que se construyan (categorías, denuncias, cambio de estado, etc.).

---

## 6. Errores ya resueltos (por si vuelven a aparecer)

Durante el desarrollo aparecieron algunos errores típicos de configuración de entorno, ya solucionados:

- **`Failed to open stream: vendor/autoload.php`** → faltaba correr `composer install` (crea la carpeta `vendor/` con las dependencias).
- **`could not find driver` (pgsql)** → faltaba instalar la extensión de PHP para PostgreSQL: `sudo apt install php8.5-pgsql`.
- **`ext-xml missing`** al correr `composer install` → faltaba instalar `sudo apt install php8.5-xml`.
- **`The route api/register could not be found`** → en Laravel 13, el archivo `routes/api.php` no se carga automáticamente. Hubo que agregarlo manualmente en `bootstrap/app.php`, dentro de `withRouting(...)`, agregando la línea `api: __DIR__.'/../routes/api.php',`.

Si alguien más del equipo instala el proyecto en su computadora y le aparecen estos mismos errores, ya se sabe exactamente cómo resolverlos.

---

## 7. Qué falta por hacer (pendientes)

Esta es la lista completa de lo que sigue, en el orden en que se planeó construir:

### Pendiente inmediato
- **Controlador de Categorías** (`CategoriaController`): un endpoint simple que devuelva el listado de categorías (para que Flutter pueda mostrar el dropdown de "tipo de problema" al crear una denuncia).

### Pendientes después
- **Controlador de Denuncias** (`DenunciaController`): el más grande — crear denuncia, listar denuncias (con filtros por categoría/estado), ver una denuncia específica, y listar "mis denuncias" (las del usuario logueado).
- **Controlador de Estados** (`EstadoController`): endpoint para que un usuario con rol `municipal` cambie el estado de una denuncia, y que ese cambio quede registrado automáticamente en `historial_estados`.
- **Resources**: clases que formatean cómo se ve la respuesta JSON final (para no exponer datos innecesarios ni desordenados al frontend).
- **Rutas**: ir agregando cada nuevo endpoint a `routes/api.php` a medida que se construyen los controladores.
- **Servicio de subida de fotos a Supabase Storage**: ahora mismo el campo `foto_url` existe en la base de datos, pero no hay ningún código que efectivamente suba una imagen y guarde su link ahí. Falta construir esa conexión.
- **CORS**: configurar que el backend acepte peticiones desde el dominio donde corra Flutter Web (por ahora no es urgente porque se está probando todo con `curl`, pero será obligatorio antes de conectar el frontend real).
- **Pruebas finales de todos los endpoints juntos** antes de conectar con Flutter.

### Fuera del backend (no es parte de este documento, pero relacionado)
- Construcción del frontend en Flutter Web.
- Despliegue del backend a un hosting real (Railway o Render), ya que por ahora solo corre en `localhost` de una computadora.

---

## 8. Cómo continuar si alguien más del equipo retoma esto

1. Clonar el repositorio y entrar a `backend-laravel/`.
2. Pedir el archivo `.env` (con las credenciales de Supabase) a quien lo tenga.
3. Correr `composer install`.
4. Correr `php artisan migrate` (por si hay migraciones nuevas que su copia local no tiene).
5. Levantar el servidor con `php artisan serve` y probar que `/api/register` y `/api/login` respondan bien con `curl`, como forma de confirmar que todo quedó bien conectado.
6. Seguir con el primer pendiente de la lista: `CategoriaController`.

Cualquier duda de "por qué se hizo así" en alguna parte específica del código, revisar los comentarios dentro de cada archivo — se dejó explicado el propósito de cada bloque importante.
