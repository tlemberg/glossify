import jinja2
import os

from flask                import Flask
from flask.ext            import restful
from flask.ext.cors       import CORS
from flask.ext.pymongo    import PyMongo
from flask.ext.sqlalchemy import SQLAlchemy
from json                 import JSONEncoder
from bson.objectid        import ObjectId
from flask.ext.mail       import Mail


template_folder = None
if 'ISDEV' in os.environ:
	template_folder='/home/ubuntu/projects/glossify/web/templates'
else:
	template_folder='/var/www/glossify/web/templates'

# App
app_instance = None
if 'ISDEV' in os.environ:
	app_instance = Flask('tenk')
	print "RUNNING IN DEV MODE"
else:
	app_instance = Flask('tenk',
		template_folder=template_folder,
		static_folder='/var/www/glossify/web/static')

# CORS
CORS(app_instance, resources=r'/api/*', allow_headers='Content-Type')

# API
api = restful.Api(app_instance)

# Config the app
app_instance.config['DEBUG'] = True
app_instance.config['SECRET_KEY'] = 'super-secret'

app_instance.config['MONGO_HOST'] = 'glossify.io'
app_instance.config['MONGO_PORT'] = '27017'
app_instance.config['mongo.db.NAME'] = 'tenk'
app_instance.config['MONGO_USERNAME'] = 'tlemberg'
app_instance.config['MONGO_PASSWORD'] = 'tlemberg'

# Mongo DB
mongo = PyMongo(app_instance)

# Mail
mail = Mail(app_instance)

# Domains
if os.environ.get('ISDEV'):
	if os.environ.get('ISLOCAL'):
		app_domain = "http://glossify.io:%s" % os.environ['DEV_APP_PORT']
		web_domain = "https://glossify.io:%s" % os.environ['DEV_WEB_PORT']
	else:
		app_domain = "http://localhost:%s" % os.environ['DEV_APP_PORT']
		web_domain = "https://localhost:%s" % os.environ['DEV_WEB_PORT']
else:
	app_domain = "http://glossify.io"
	web_domain = "https://glossify.io"


# jinja2
app_instance.jinja_loader = jinja2.ChoiceLoader([
    app_instance.jinja_loader,
    jinja2.FileSystemLoader('/home/ubuntu/projects/glossify/web/app/templates'),
])

