# ClosetSocialBackend

Backend inicial en Vapor para la red social de ropa.

## Qué trae ya

- registro de usuario
- login con token de sesión
- persistencia real con SQLite
- timeline mock protegido por bearer token
- endpoints base de armario, outfits y perfil
- alta de prendas asociadas al usuario autenticado
- todo con `async/await`

## Endpoints

- `GET /health`
- `POST /auth/register`
- `POST /auth/login`
- `GET /api/timeline`
- `GET /api/closet`
- `POST /api/closet`
- `GET /api/outfits`
- `GET /api/profile`

## Arranque

```bash
swift run Run
```

## Credenciales de prueba

- `pablo@closetsocial.app` / `password123`
- `ana@closetsocial.app` / `password123`

## Base de datos

El backend crea un fichero SQLite local:

- `closet-social.sqlite`
