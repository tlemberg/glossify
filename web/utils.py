from flask import Flask
from flask.ext import restful
from flask.ext.pymongo import PyMongo
from flask.ext.sqlalchemy import SQLAlchemy
from flask.ext.cors import CORS
import json
from bson.objectid import ObjectId
from flask.ext.mail import Mail

# App
app = Flask('tenk')

# CORS
CORS(app, resources=r'/api/*', allow_headers='Content-Type')

# API
api = restful.Api(app)

# Mongo DB
mongo = PyMongo(app)

# Config the app
app.config['DEBUG'] = True
app.config['SECRET_KEY'] = 'super-secret'

# Helper methods
class JSONEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        return json.JSONEncoder.default(self, o)

def json_result(obj):
	return JSONEncoder().encode(obj)

# Mail
mail = Mail(app)

# Domains
web_domain = 'glossify.net'
app_domain = '192.168.0.108:8000'