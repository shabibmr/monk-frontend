# api_client

**Status:** handwritten interim client (backend OpenAPI T0.6 not complete).

When backend T0.6 publishes a full OpenAPI → Dart generation pipeline:

1. Delete hand-written sources under `lib/src/`.
2. Commit generated output here.
3. **Never hand-edit** generated files thereafter.

Endpoints currently implemented match Nest controllers:

- `GET /health`, `GET /health/ready`
- `POST /auth/register|login|refresh|logout|verify-email|resend-verification`
- `POST /auth/password/forgot|reset`
- `GET /auth/sessions`, `DELETE /auth/sessions/:id`
