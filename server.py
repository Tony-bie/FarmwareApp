from fastapi import FastAPI, HTTPException, Query, File, UploadFile, Form
from pydantic import BaseModel, EmailStr
from datetime import date
from typing import Optional
import re
import requests
import os
from passlib.context import CryptContext
from passlib.exc import UnknownHashError
from fastapi.responses import RedirectResponse, HTMLResponse


# -------------------- Encriptación --------------------
pwd_context = CryptContext(
    schemes=["argon2", "bcrypt_sha256", "bcrypt"],
    default="argon2",
    deprecated="auto",
)

app = FastAPI()

# -------------------- Config Supabase --------------------
SUPABASE_URL = "https://jmgjpgadgrkihthvkide.supabase.co/rest/v1/"
SUPABASE_BUCKET = "Images"

SUPABASE_REGISTER = "users"
SUPABASE_IMAGES_TABLE = "photos"

SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")


def headers():
    return {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Accept": "application/json",
        "Content-Type": "application/json"
    }


# ---------------------- Modelos ----------------------
class User(BaseModel):
    first_name: str
    last_name: str
    email: Optional[EmailStr] = None
    phonenumber: Optional[str] = None
    password: str
    username: str
    birthday: date

class LoginIn(BaseModel):
    identifier: str
    password: str

class UpdateUser(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phonenumber: Optional[str] = None
    username: Optional[str] = None
    current_password: Optional[str] = None
    new_password: Optional[str] = None
    confirm_password: Optional[str] = None

class DeleteIn(BaseModel):
    current_password: str
    
@app.get("/")
def root():
    return RedirectResponse(url="/login")


# ---------------------- Obtener imágenes (tabla images original) ----------------------
@app.get("/images")
def get_images():
    if not SUPABASE_KEY:
        return {"error": "Service role key no configurada"}

    response = requests.get(SUPABASE_URL + "images", headers=headers())
    if response.status_code != 200:
        return {"error": "Error al consultar Supabase", "details": response.text}

    return response.json()


# ---------------------- Registro ----------------------
@app.post("/register")
def register(reg: User):
    password_hash = pwd_context.hash(reg.password)

    email_norm = reg.email.strip().lower() if reg.email else None
    number_norm = re.sub(r"\D", "", reg.phonenumber) if reg.phonenumber else None

    data = {
        "first_name": reg.first_name,
        "last_name": reg.last_name,
        "password_hash": password_hash,
        "username": reg.username,
        "birthday": str(reg.birthday)
    }

    if email_norm is not None:
        data["email"] = email_norm
    if number_norm is not None:
        data["phonenumber"] = number_norm

    response = requests.post(SUPABASE_URL + SUPABASE_REGISTER, headers=headers(), json=data, timeout=10)

    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.text)

    return {"message": "User registered successfully"}


# ---------------------- Login ----------------------
@app.post("/login")
def login(log: LoginIn):
    if not SUPABASE_KEY:
        raise HTTPException(status_code=500, detail="Service role key no configurada")

    ident = log.identifier.strip()
    PHONE_RE = re.compile(r"^\d{8,15}$")

    if "@" in ident:
        where = {"email": f"eq.{ident}"}
    elif PHONE_RE.match(ident):
        where = {"phonenumber": f"eq.{ident}"}
    else:
        where = {"username": f"eq.{ident}"}

    url = SUPABASE_URL + SUPABASE_REGISTER
    params = {"select": "id_user,username,email,phonenumber,password_hash", **where, "limit": 1}

    resp = requests.get(url, headers=headers(), params=params, timeout=10)
    if not resp.ok:
        raise HTTPException(status_code=resp.status_code, detail=resp.text)

    rows = resp.json()
    if not rows:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    row = rows[0]
    stored_hash = row.get("password_hash") or ""

    try:
        if not pwd_context.verify(log.password, stored_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")
    except UnknownHashError:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    params_pub = {
        "select": "id_user,first_name,last_name,email,birthday,created_at",
        "id_user": f"eq.{row['id_user']}",
        "limit": 1
    }
    resp_pub = requests.get(url, headers=headers(), params=params_pub, timeout=10)
    if not resp_pub.ok:
        raise HTTPException(status_code=resp_pub.status_code, detail=resp_pub.text)

    pub_rows = resp_pub.json()
    if not pub_rows:
        return {"message": "Login successful"}

    return {"user": pub_rows[0]} if pub_rows else {"message": "Login successful"}


# ---------------------- Obtener perfil ----------------------
@app.get("/me")
def get_me(user_id: int = Query(..., alias="user_id")):
    url = SUPABASE_URL + SUPABASE_REGISTER
    params = {
        "select": "id_user, first_name, last_name, email, phonenumber, username",
        "id_user": f"eq.{user_id}",
        "limit": 1
    }
    resp = requests.get(url, headers=headers(), params=params, timeout=10)
    if not resp.ok:
        raise HTTPException(status_code=resp.status_code, detail=resp.text)
    rows = resp.json()
    if not rows:
        raise HTTPException(status_code=404, detail="User not found")
    return rows[0]


# ---------------------- Actualizar usuario ----------------------
@app.patch("/users/{user_id}")
def update_user(user_id: int, body: UpdateUser):
    data = body.model_dump(exclude_unset=True)

    if data.get("email") is not None:
        data["email"] = data["email"].strip().lower()
    if data.get("phonenumber") is not None:
        data["phonenumber"] = re.sub(r"\D", "", data["phonenumber"])

    wants_pwd = all(k in data for k in ("current_password", "new_password", "confirm_password"))
    url = SUPABASE_URL + SUPABASE_REGISTER

    if wants_pwd:
        if data["new_password"] != data["confirm_password"]:
            raise HTTPException(status_code=400, detail="Passwords do not match")

        r = requests.get(
            url,
            headers=headers(),
            params={"select": "password_hash", "id_user": f"eq.{user_id}", "limit": 1},
            timeout=10,
        )
        if not r.ok:
            raise HTTPException(status_code=r.status_code, detail=r.text)
        rows = r.json()
        if not rows:
            raise HTTPException(status_code=404, detail="User not found")

        stored = rows[0].get("password_hash") or ""
        try:
            if not pwd_context.verify(data["current_password"], stored):
                raise HTTPException(status_code=401, detail="Current password incorrect")
        except UnknownHashError:
            raise HTTPException(status_code=400, detail="Invalid stored hash")

        data["password_hash"] = pwd_context.hash(data["new_password"])
        for k in ("current_password", "new_password", "confirm_password"):
            data.pop(k, None)

    data = {k: v for k, v in data.items() if v is not None}
    if not data:
        return {"message": "Nothing to update"}

    rp = requests.patch(
        url,
        headers=headers(),
        params={"id_user": f"eq.{user_id}"},
        json=data,
        timeout=10,
    )
    if not rp.ok:
        raise HTTPException(status_code=rp.status_code, detail=rp.text)

    rg = requests.get(
        url,
        headers=headers(),
        params={
            "select": "id_user,first_name,last_name,email,phonenumber,username,birthday,created_at",
            "id_user": f"eq.{user_id}",
            "limit": 1,
        },
        timeout=10,
    )
    if not rg.ok:
        raise HTTPException(status_code=rg.status_code, detail=rg.text)

    out = rg.json()
    return out[0] if out else {"message": "Updated"}


# ---------------------- Eliminar usuario ----------------------
@app.delete("/users/{user_id}")
def delete_user(user_id: int, body: DeleteIn):
    if not SUPABASE_KEY:
        raise HTTPException(status_code=500, detail="Service role key no configurada")
    url = SUPABASE_URL + SUPABASE_REGISTER

    req = requests.get(
        url,
        headers=headers(),
        params={"select": "password_hash", "id_user": f"eq.{user_id}", "limit": 1},
        timeout=10,
    )

    if not req.ok:
        raise HTTPException(status_code=req.status_code, detail=req.text)
    rows = req.json()
    if not rows:
        raise HTTPException(status_code=404, detail="User not found")

    stored = rows[0].get("password_hash") or ""
    try:
        if not pwd_context.verify(body.current_password, stored):
            raise HTTPException(status_code=401, detail="Current password incorrect")
    except UnknownHashError:
        raise HTTPException(status_code=400, detail="Invalid stored hash")

    del_headers = headers() | {"Prefer": "return=representation"}
    d = requests.delete(
        url,
        headers=del_headers,
        params={"id_user": f"eq.{user_id}"},
        timeout=10,
    )

    if not d.ok:
        raise HTTPException(status_code=d.status_code, detail=d.text)

    try:
        deleted = d.json()
        return {"deleted": deleted}
    except ValueError:
        return {"message": "User deleted successfully"}


@app.get("/photos")
def get_photos():
    """Obtiene todas las fotos desde la tabla 'photos'."""
    if not SUPABASE_KEY:
        return {"error": "Service role key no configurada"}

    response = requests.get(SUPABASE_URL + SUPABASE_IMAGES_TABLE, headers=headers())
    if response.status_code != 200:
        return {"error": "Error al consultar Supabase", "details": response.text}

    return response.json()


@app.post("/upload")
async def upload_image(
    etapa: str = Form(...),
    comentario: str = Form(None),
    file: UploadFile = File(...)
):
    """Sube una imagen al bucket y crea un registro en la tabla 'photos'."""
    if not SUPABASE_KEY:
        return {"error": "Service role key no configurada"}

    file_bytes = await file.read()
    filename = file.filename

    # 1️⃣ Subir imagen al bucket
    upload_url = f"https://jmgjpgadgrkihthvkide.supabase.co/storage/v1/object/{SUPABASE_BUCKET}/{filename}"
    upload_headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/octet-stream"
    }

    upload_response = requests.put(upload_url, headers=upload_headers, data=file_bytes)
    if upload_response.status_code not in (200, 201):
        return {"error": "Error subiendo imagen al bucket", "details": upload_response.text}

    # 2️⃣ Crear registro en la tabla 'photos'
    record_payload = {
        "etapa": etapa,
        "img_url": f"https://jmgjpgadgrkihthvkide.supabase.co/storage/v1/object/public/{SUPABASE_BUCKET}/{filename}",
        "comentario": comentario
    }

    insert_response = requests.post(
        SUPABASE_URL + SUPABASE_IMAGES_TABLE,
        headers=headers(),
        json=record_payload
    )
    if insert_response.status_code not in (200, 201):
        return {"error": "Error insertando registro en tabla photos", "details": insert_response.text}

    return {"message": "Imagen subida y registro creado", "url": record_payload["img_url"]}
