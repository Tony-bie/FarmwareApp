# Farmware API & (Optional) Admin — README

This document explains the stack, local setup, environment variables, and **exact steps to release** the API (and the Admin page if you choose to ship one). It also includes your deployed API link.

---

## TL;DR

* **Deployed API (Production):** [https://farmwareapp.onrender.com](https://farmwareapp.onrender.com)
* **Interactive docs (OpenAPI):** `https://farmwareapp.onrender.com/docs` (FastAPI default)
* **Health check (example):** `GET /photos` → `200 OK` 

> If `/docs` or `/healthz` are not yet available, add them following the snippets below.

---


## 2) Environment Variables

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
git clone https://github.com/Tony-bie/FarmwareApp.git
cd FarmwareApp

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

**— Render Web Service (GitHub Auto Deploy)**

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



