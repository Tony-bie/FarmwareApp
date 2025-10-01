from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, EmailStr
from datetime import date
import requests
import os
from passlib.context import CryptContext


app = FastAPI()

# URL de tu REST API de Supabase
SUPABASE_URL = "https://jmgjpgadgrkihthvkide.supabase.co/rest/v1/images"

# La service_role key de Supabase (solo en backend)
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

class RegisterUser(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    password: str
    confirm_password: str
    birthday: date

def headers():
    return{
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Accept": "application/json"
    }

@app.get("/images")
def get_images():
    if not SUPABASE_KEY:
        return {"error": "Service role key no configurada"}

    response = requests.get(SUPABASE_URL, headers=headers())
    
    if response.status_code != 200:
        return {"error": "Error al consultar Supabase", "details": response.text}

    return response.json()

@app.post("/register")
def register(user: RegisterUser):
    if user.password != user.confirm_password:
        raise HTTPException(status_code=400, detail= "Password do not match")
    password_hash = pwd_context.hash(user.password)
    
    data = {
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "password_hash": user.password_hash,
        "birthdat": user.birthday
    }
    response = requests.post(SUPABASE_URL, headers=headers(), json=data)
    
    if not response.ok:
        raise HTTPException(status_code=response.status_code, detail=response.text)
    
    return{"message": "User registered successfully"}
    
