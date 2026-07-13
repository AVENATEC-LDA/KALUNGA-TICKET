# Deployment Guide

This document is the canonical deployment guide for this repository.
It is the single source of truth for deploying Hi.Events in production, including Dokploy-based deployments.

If deployment instructions appear elsewhere in this repository, follow this guide first.

## Official references

- Official Hi.Events deployment documentation: https://hi.events/docs/getting-started/deploying
- This repository deployment assets: [docker/dokploy/docker-compose.yml](docker/dokploy/docker-compose.yml), [docker/dokploy/.env.example](docker/dokploy/.env.example), and [docker/dokploy/README.md](docker/dokploy/README.md)

## Recommended deployment model

Hi.Events supports two deployment approaches:

1. All-in-one container
   - Simple and fast for testing.
   - Best for quick trials.

2. Separate services for production
   - Recommended for production and for Dokploy.
   - Use one service for the backend, one for the frontend, one for the queue worker, and one for the scheduler.

For Dokploy, use the separate-services model.

## Architecture

### Backend service
- Build context: [backend](backend)
- Dockerfile: [backend/Dockerfile](backend/Dockerfile)
- Purpose: Laravel API, admin UI, business logic, migrations
- Exposed port: 8080

### Frontend service
- Build context: [frontend](frontend)
- Dockerfile: [frontend/Dockerfile.ssr](frontend/Dockerfile.ssr)
- Purpose: SSR frontend
- Exposed port: 5678

### Queue worker
- Purpose: process Laravel queues for background jobs and webhooks
- Command: `php artisan queue:work --queue=default,webhook-queue --sleep=3 --tries=3 --timeout=60`

### Scheduler
- Purpose: run Laravel scheduled tasks
- Command: `while true; do php artisan schedule:run --no-interaction; sleep 60; done`

## Prerequisites

Before deploying, prepare:

- A PostgreSQL database
- A Redis instance
- An object storage service compatible with S3, such as Cloudflare R2
- A mail provider or SMTP relay
- A public domain and HTTPS/SSL
- Strong secrets for `APP_KEY` and `JWT_SECRET`

## Environment variables

Copy [docker/dokploy/.env.example](docker/dokploy/.env.example) to a real environment file and fill in the values.

### Required secrets
- `APP_KEY`
- `JWT_SECRET`
- `APP_URL`
- `APP_FRONTEND_URL`

### Database
- `DB_HOST`
- `DB_PORT`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`
- `DATABASE_URL`

### Redis
- `REDIS_HOST`
- `REDIS_PORT`
- `REDIS_PASSWORD`
- `REDIS_URL`

### Object storage
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `AWS_PUBLIC_BUCKET`
- `AWS_PRIVATE_BUCKET`
- `AWS_ENDPOINT`
- `AWS_USE_PATH_STYLE_ENDPOINT`

### Frontend URLs
- `VITE_FRONTEND_URL`
- `VITE_API_URL_CLIENT`
- `VITE_API_URL_SERVER`

## Dokploy deployment steps

1. Create the PostgreSQL and Redis services in Dokploy.
2. Create a backend service using [backend/Dockerfile](backend/Dockerfile).
3. Create a frontend service using [frontend/Dockerfile.ssr](frontend/Dockerfile.ssr).
4. Create a queue worker service using the same backend image and the queue command above.
5. Create a scheduler service using the same backend image and the scheduler command above.
6. Attach the environment file from [docker/dokploy/.env.example](docker/dokploy/.env.example) to the services.
7. Point the public domains to the backend and frontend services.
8. After the backend is up, run migrations:

```bash
php artisan migrate --force
```

## Storage and CDN

For production, use object storage instead of local disk storage.
If you use Cloudflare R2, set:

- `FILESYSTEM_PUBLIC_DISK=s3-public`
- `FILESYSTEM_PRIVATE_DISK=s3-private`
- `AWS_ENDPOINT=https://<accountid>.r2.cloudflarestorage.com`
- `APP_CDN_URL` to the public URL of your bucket or a custom domain mapped to it

## Operational notes

- Set `APP_ENV=production` and `APP_DEBUG=false`.
- Set `QUEUE_CONNECTION=redis` for production.
- Configure mail and Stripe before going live.
- Do not rely on local file storage for production uploads.

## Validation checklist

Before opening the site to users, confirm:

- The backend responds correctly on its public domain.
- The frontend loads on its public domain.
- The queue worker is running without errors.
- The scheduler is running without errors.
- Migrations completed successfully.
- Files upload correctly to your storage backend.
