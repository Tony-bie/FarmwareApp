from fastapi import FastAPI
import requests
import os

app = FastAPI()

# URL de tu REST API de Supabase
SUPABASE_URL = "https://jmgjpgadgrkihthvkide.supabase.co/rest/v1/images"

# La service_role key de Supabase (solo en backend)
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

@app.get("/images")
def get_images():
    if not SUPABASE_KEY:
        return {"error": "Service role key no configurada"}

    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Accept": "application/json"
    }

    response = requests.get(SUPABASE_URL, headers=headers)
    
    if response.status_code != 200:
        return {"error": "Error al consultar Supabase", "details": response.text}

    return response.json()
