"""Seed (or update) the LiteLLM gateway as a model endpoint in Odysseus.

Copy this file into your odysseus/ clone, then run it with the Odysseus venv
python from that directory:
    venv\\Scripts\\python.exe seed_gateway_endpoint.py

The gateway API key is read from LITELLM_MASTER_KEY (or the gateway .env),
so set it to the same value you put in gateway/.env.
"""
import os
import sys
import uuid

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)

from core.database import SessionLocal, ModelEndpoint, Base, engine

Base.metadata.create_all(bind=engine)

BASE_URL = "http://localhost:4000/v1"
API_KEY = os.environ.get("LITELLM_MASTER_KEY", "sk-local-CHANGE-ME")

db = SessionLocal()
try:
    ep = db.query(ModelEndpoint).filter(ModelEndpoint.base_url == BASE_URL).first()
    if ep is None:
        ep = ModelEndpoint(id=uuid.uuid4().hex, name="AI Stack Gateway", base_url=BASE_URL)
        db.add(ep)
        action = "Created"
    else:
        action = "Updated"

    ep.name = "AI Stack Gateway (auto -> Groq/Gemini/OpenRouter)"
    ep.api_key = API_KEY
    ep.is_enabled = True
    ep.endpoint_kind = "proxy"
    ep.model_refresh_mode = "auto"
    ep.supports_tools = True
    ep.pinned_models = '["auto"]'
    ep.cached_models = '["auto", "gemini", "openrouter"]'
    ep.owner = None  # shared / visible to all users

    db.commit()
    print(f"{action} endpoint id={ep.id}")

    print("--- current model_endpoints ---")
    for e in db.query(ModelEndpoint).all():
        print(f"  {e.name} | {e.base_url} | enabled={e.is_enabled} | pinned={e.pinned_models}")
finally:
    db.close()

print("SEED_DONE")
