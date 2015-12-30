import os, time
from fabric.api import run, cd, sudo, local, task


@task
def launch_prod():
	with cd('/var/www/prod/glossify'):
		sudo("git fetch --all")
		sudo("git reset --hard")
		sudo("apachectl restart")


@task
def dump_mongo(*args):
	collections = list(args)
	out_dir = '/data/dump'
	sudo("mkdir -p %s" % out_dir)
	for collection in collections:
		sudo("mongodump --db tenk --collection %s --out %s" % (collection, out_dir))
