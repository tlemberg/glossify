import os
from fabric.api import run, cd, sudo, local

def launch_prod():
	with cd('/var/www/prod/glossify'):
		sudo("git fetch --all")
		sudo("git reset --hard")
		sudo("apachectl restart")


def dump_mongo():
	collections = [
		'user_profiles',
		'user_progress',
		'phrases_fr',
	]
	for collection in collections:
		sudo("mongodump --db tenk --collection %s --out /data/dump" % collection)
		
