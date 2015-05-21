import jinja2

from flask                import Flask
from flask.ext            import restful
from flask.ext.cors       import CORS
from flask.ext.pymongo    import PyMongo
from flask.ext.sqlalchemy import SQLAlchemy
from json                 import JSONEncoder
from bson.objectid        import ObjectId
from flask.ext.mail       import Mail


# App
app_instance = Flask('tenk')

# CORS
CORS(app_instance, resources=r'/api/*', allow_headers='Content-Type')

# API
api = restful.Api(app_instance)

# Mongo DB
mongo = PyMongo(app_instance)

# Config the app
app_instance.config['DEBUG'] = True
app_instance.config['SECRET_KEY'] = 'super-secret'

# Helper methods
class JSONEncoder(JSONEncoder):
    def default(self, o):
        if isinstance(o, ObjectId):
            return str(o)
        return JSONEncoder.default(self, o)

# Mail
mail = Mail(app_instance)

# Domains
web_domain = 'glossify.net'
app_domain = '192.168.0.108:8000'

# jinja2
app_instance.jinja_loader = jinja2.ChoiceLoader([
    app_instance.jinja_loader,
    jinja2.FileSystemLoader('/home/ubuntu/projects/glossify/web/app/templates'),
])

