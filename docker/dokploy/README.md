# Dokploy deployment notes

This folder contains a Dokploy-friendly Compose layout for deploying Hi.Events with separate services for:

- backend web app
- frontend SSR app
- queue worker
- scheduler/cron

## Recommended deployment model

Use one Dokploy service for each component:

1. Backend service using the backend Dockerfile
2. Frontend service using the frontend SSR Dockerfile
3. Queue worker service running Laravel queues
4. Scheduler service running Laravel schedule

## Required environment variables

Copy [.env.example](.env.example) to a real `.env` file and set all values before deploying.

### Minimum requirements

- `APP_KEY`
- `JWT_SECRET`
- `APP_URL`
- `APP_FRONTEND_URL`
- `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`
- `REDIS_HOST`
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_PUBLIC_BUCKET`, `AWS_PRIVATE_BUCKET`, `AWS_ENDPOINT`

## Notes

- The backend and frontend should point to the same public domain shape you intend to expose in Dokploy.
- For production, prefer a managed PostgreSQL service and a managed Redis service or a private Dokploy service.
- Cloudflare R2 is supported via the S3-compatible AWS settings.
- For the backend web service, Dokploy should expose port `8080` and for the frontend service port `5678`.

## Example secrets

Generate secrets with:

```bash
openssl rand -base64 32
```

Use the output for `APP_KEY` and `JWT_SECRET`.
