from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from datetime import date
import requests
import os
from passlib.context import CryptContext
from passlib.exc import UnknownHashError


pwd_context = CryptContext(
    schemes=["argon2", "bcrypt_sha256", "bcrypt"],
    default="argon2",
    deprecated="auto",
)

app = FastAPI()

# URL de tu REST API de Supabase
SUPABASE_URL = "https://jmgjpgadgrkihthvkide.supabase.co/rest/v1/"


SUPABASE_IMAGE="images"
SUPABASE_REGISTER = "users"

# La service_role key de Supabase (solo en backend)
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")


class User(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    confirm_password: str
    birthday: date
    
class LoginIn(BaseModel):
    email: EmailStr
    password: str
    
def headers():
    return{
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Accept": "application/json",
        "Content-Type": "application/json"
        }

@app.get("/images")
def get_images():
    if not SUPABASE_KEY:
        return {"error": "Service role key no configurada"}

    response = requests.get(SUPABASE_URL + SUPABASE_IMAGE, headers=headers())
    
    if response.status_code != 200:
        return {"error": "Error al consultar Supabase", "details": response.text}

    return response.json()

@app.post("/register")
def register(reg: User):
    if reg.password != reg.confirm_password:
        raise HTTPException(status_code=400, detail= "Password do not match")
    password_hash = pwd_context.hash(reg.password)
    
    email_norm = reg.email.strip().lower()

    
    data = {
        "first_name": reg.first_name,
        "last_name": reg.last_name,
        "email": email_norm,
        "password_hash": password_hash,
        "birthday": str(reg.birthday)
    }
    response = requests.post(SUPABASE_URL + SUPABASE_REGISTER, headers=headers(), json=data, timeout=10)
    
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.text)
    
    return{"message": "User registered successfully"}
    
@app.post("/login")
def login(log: LoginIn):
    if not SUPABASE_KEY:
        raise HTTPException(status_code=500, detail="Service role key no configurada")

    email_norm = log.email.strip().lower()

    url = SUPABASE_URL + SUPABASE_REGISTER
    params = {
        "select": "id_user,email,password_hash",
        "email": f"ilike.{email_norm}",
        "limit": 1
    }

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

