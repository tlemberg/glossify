import os, time
from fabric.api import run, cd, sudo, local, task


@task
def launch_prod():
	with cd('/var/www/glossify'):
		sudo("git fetch --all")
		sudo("git reset --hard")
		sudo("mv /var/www/glossify/app/www/coffee/src/config-prod.coffee /var/www/glossify/app/www/coffee/src/config.coffee")
		with cd('/var/www/glossify/app/scripts'):
			sudo('./compile_coffee')
			sudo('./compile_less')
		sudo("apachectl restart")


@task
def dump_mongo(*args):
	collections = list(args)
	out_dir = '/data/dump'
	sudo("mkdir -p %s" % out_dir)
	for collection in collections:
		sudo("mongodump --db tenk --collection %s --out %s" % (collection, out_dir))
