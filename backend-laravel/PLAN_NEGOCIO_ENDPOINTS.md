# Plan para completar la lógica de negocio del backend

## Objetivo

Completar la parte funcional del backend de denuncias para que el frontend pueda:

- listar categorías,
- crear denuncias,
- ver denuncias,
- consultar denuncias del usuario actual,
- cambiar estados de denuncia y registrar historial,
- responder con mensajes consistentes y validaciones adecuadas.

## Estado actual

La base técnica del proyecto ya está preparada:

- Laravel en backend-laravel
- autenticación con Sanctum
- modelos y migraciones para denuncias, categorías y historial
- validaciones de request creadas
- middleware de roles definido

Lo que faltaba era conectar ese dominio con la API real.

## Cambios implementados

### Rutas agregadas

- GET /api/categorias
- GET /api/denuncias
- POST /api/denuncias
- GET /api/denuncias/mis-denuncias
- GET /api/denuncias/{id}
- PATCH /api/denuncias/{id}/estado
- GET /api/denuncias/{id}/historial

### Controladores agregados

- CategoriaController
- DenunciaController

### Reglas importantes

- la denuncia se crea con el usuario autenticado
- el estado inicial es pendiente
- solo usuarios con rol municipal pueden cambiar estado
- cada cambio de estado queda registrado en historial_estados
- las respuestas usan JSON uniforme con success y message

## Validación recomendada

1. Registrar usuario.
2. Iniciar sesión.
3. Consultar categorías.
4. Crear denuncia con datos válidos.
5. Ver denuncias generales.
6. Ver denuncias del usuario autenticado.
7. Cambiar estado como municipal.
8. Revisar historial de cambios.

## Siguientes pasos opcionales

- integrar subida real de fotos a Supabase Storage,
- añadir recursos de serialización del API,
- revisar CORS para Flutter Web,
- añadir pruebas automatizadas para los endpoints.
