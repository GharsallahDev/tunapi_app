from flask import Flask
from flask_cors import CORS
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)

CORS(app)

from modules.backend.routes import mod as backend_mod
from modules.api.routes import mod as api_mod

app.register_blueprint(backend_mod)
app.register_blueprint(api_mod, url_prefix='/api')
