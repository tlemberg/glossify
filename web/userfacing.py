from flask import Flask
from flask import render_template
from flask.ext.pymongo import PyMongo
from flask import request, redirect, jsonify

from operator import attrgetter
from models.phrases import get_total_phrase_counts

from bson.objectid import ObjectId
import json

from utils import app, mongo

@app.route('/')
def hello_world():
	return 'Hello World!'