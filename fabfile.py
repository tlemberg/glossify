import os
from fabric.api import run, cd, sudo, local

def launch_prod():
	with cd('/var/www/prod/glossify'):
		sudo("git fetch --all")
		sudo("git reset --hard")
		sudo("apachectl restart")


def dump_mongo():
	sudo("mongodump --db tenk --collection phrases_fr --out /data/dump")
		
