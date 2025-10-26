# Farmware API & (Optional) Admin — README

This document explains the stack, local setup, environment variables, and **exact steps to release** the API (and the Admin page if you choose to ship one). It also includes your deployed API link.

---

## TL;DR

* **Deployed API (Production):** [https://farmwareapp.onrender.com](https://farmwareapp.onrender.com)
* **Interactive docs (OpenAPI):** `https://farmwareapp.onrender.com/docs` (FastAPI default)
* **Health check (example):** `GET /healthz` → `200 OK` *(add route if missing)*

> If `/docs` or `/healthz` are not yet available, add them following the snippets below.

---

## 1) Stack

**Backend**

* Language/runtime: **Python 3.12**
* Web framework: **FastAPI** (+ Pydantic v2)
* ASGI server: **Uvicorn** (production behind Render)
* Database: **PostgreSQL** (Render PostgreSQL or Supabase Postgres)
* ORM & migrations: **SQLAlchemy** + **Alembic** (or SQLModel)
* Auth: **JWT** (PyJWT) and/or API Key header (e.g., `apikey`)
* CORS: `fastapi.middleware.cors`

**Infra/DevOps**

* Hosting: **Render** (Web Service) – auto deploy from GitHub main
* Optional DB: **Render PostgreSQL** *(or external: Supabase)*
* Optional Admin UI: **Remix / React** hosted on **Vercel/Netlify/Render**
* CI/CD: **GitHub Actions** (lint + test + build)

> You can reference the admin setup style from: `wizeline/remix-project-lab` (Remix, environment-driven config, and deploy workflow).

---

## 2) Project Structure (example)

```
root/
├─ app/
│  ├─ main.py              # FastAPI app entry
│  ├─ api/                 # Routers: auth, users, etc.
│  ├─ models/              # SQLAlchemy/SQLModel models
│  ├─ schemas/             # Pydantic schemas
│  ├─ core/                # settings, security (JWT), deps
│  ├─ db/                  # session, init, seed
│  └─ __init__.py
├─ alembic/                # migrations
├─ alembic.ini
├─ requirements.txt        # or pyproject.toml
├─ render.yaml             # (optional) Render blueprint
├─ .github/workflows/ci.yml
├─ .env.example
└─ README.md
```

---

## 3) Environment Variables

Create `.env` (copy from `.env.example`). At minimum:

```
# App
ENV=production  # or development
PORT=8000       # Render sets $PORT automatically

# Security
JWT_SECRET=change-me
JWT_ALG=HS256
API_KEY_REQUIRED=true
API_KEY=your-strong-api-key

# Database (choose one)
DATABASE_URL=postgresql+psycopg://USER:PASSWORD@HOST:PORT/DB
# or Supabase
SUPABASE_DB_URL=postgresql+psycopg://USER:PASSWORD@HOST:PORT/DB

# CORS
CORS_ORIGINS=https://your-ios-app-bundle,https://your-admin-domain
```

> On **Render**, set these in the “Environment” tab of your Web Service and (if used) your PostgreSQL connection string.

---

## 4) Local Development

**Prerequisites**

* Python **3.12**+
* Postgres **14+** (local or Docker)
* `pip` (or `uv`/`poetry`), `alembic`

**Setup**

```bash
# clone
git clone <your-repo-url>
cd <your-repo>

# env
cp .env.example .env
# edit .env with local DB URL and secrets

# install deps
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# database
alembic upgrade head    # apply migrations

# run api
uvicorn app.main:app --reload --port 8000
# open http://127.0.0.1:8000/docs
```

---

## 5) Release Process — API on Render

**Option A — Render Web Service (GitHub Auto Deploy)**

1. Push your repo to GitHub.
2. On Render → **New → Web Service** → Connect repository.
3. Environment: **Python**.
4. Build command (one of):

   * `pip install -r requirements.txt && alembic upgrade head`
5. Start command:

   * `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
6. **Environment variables**: Add those listed above (incl. `DATABASE_URL`, `JWT_SECRET`, `API_KEY`, etc.).
7. (Optional) Add a **PostgreSQL** instance in Render and copy its **internal connection string** to `DATABASE_URL`.
8. Click **Create Web Service**. Render will build and deploy on every push to the selected branch (usually `main`).

**Option B — Render Blueprint (render.yaml)**

* Commit a `render.yaml` that defines the Web Service and DB. Then in Render → **Blueprints** → **New from Blueprint** → pick your repo/branch.

**Smoke Test (post-deploy)**

```bash
curl -s -H "apikey: $API_KEY" https://farmwareapp.onrender.com/healthz
# expect: 200 OK

curl -s -H "apikey: $API_KEY" https://farmwareapp.onrender.com/docs
# should return the Swagger UI HTML
```

**Versioning**

* Bump version in `pyproject.toml` or `app/__init__.py`.
* Use semantic tags (e.g., `v1.3.0`) to mark releases.

---

## 6) (Optional) Admin Page — Remix/React

If you add an Admin UI (e.g., Users, Roles, Metrics):

**Stack**

* **Remix** (as in `wizeline/remix-project-lab`), or Next.js/React
* Deployed to **Vercel**/**Netlify**/**Render**

**Environment Variables**

```
VITE_API_BASE_URL=https://farmwareapp.onrender.com
VITE_API_KEY=your-strong-api-key
```

**Release (Vercel example)**

1. Create new Vercel project from your repo.
2. Set `VITE_API_BASE_URL`, `VITE_API_KEY` in Project Settings → Environment Variables.
3. Build command: `npm run build` (or `pnpm build`)
4. Output: `build`/`.vercel/output` depending on tooling.
5. Promote to Production after preview QA.

**Admin Routing**

* Protect routes with your JWT/API Key.
* Use server-side environment variables for secrets.

**Link (if applicable)**

* **Admin (Production):** `https://<your-admin-domain>` *(update here when live)*

---

## 7) API Endpoints (examples)

> Update names and payloads to match your code. These follow patterns you’ve used (register/login/update/delete) and require `apikey` header if enabled.

**Auth**

* `POST /register` — create account
* `POST /login` — exchange credentials for JWT
* `GET /me` — current user (JWT)

**Users**

* `PUT /users/me` — update profile
* `DELETE /users/me` — delete account

**Headers**

```
apikey: <API_KEY>
Authorization: Bearer <JWT>
Content-Type: application/json
```

**Example — Register**

```bash
curl -X POST https://farmwareapp.onrender.com/register \
  -H "Content-Type: application/json" \
  -H "apikey: $API_KEY" \
  -d '{
    "first_name": "Ana",
    "last_name": "Pérez",
    "username": "anap",
    "password": "MiPass#2024",
    "birthday": "2000-01-01",
    "email": "ana@example.com",
    "phonenumber": "5522334455"
  }'
```

---

## 8) Health Check & Docs Routes (add if missing)

**`app/main.py` (snippet)**

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Farmware API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/healthz")
async def healthz():
    return {"status": "ok"}
```

> Swagger UI will be available at `/docs` automatically if you use FastAPI.

---

## 9) Database Migrations (Alembic)

**Create a migration**

```bash
alembic revision -m "create users"
```

**Apply migrations**

```bash
alembic upgrade head
```

**Render deploy hook (build command)**

```bash
pip install -r requirements.txt && alembic upgrade head
```

---

## 10) CI/CD (GitHub Actions example)

**`.github/workflows/ci.yml`**

```yaml
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: pytest -q || true  # add tests when ready
```

> Connect Render to auto-deploy on push to `main`. Optionally, add a Render Deploy hook to run migrations post-build.

---

## 11) Security & Ops

* Enforce `API_KEY` (header `apikey`) for sensitive routes.
* JWT expiration & refresh policy.
* CORS: restrict to known origins for production.
* Backups: enable daily backups for the Postgres instance.
* Monitoring: Render logs; add Sentry/OpenTelemetry if needed.

---

## 12) Troubleshooting

* `{"detail":"No API key found in request"}` → Include `-H "apikey: $API_KEY"`.
* 500 on startup → Check `DATABASE_URL` and migrations (`alembic upgrade head`).
* `/docs` 404 → Verify FastAPI app is mounted at root and not behind a sub-router.

