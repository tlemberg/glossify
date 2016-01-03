import os, time
from fabric.api import run, cd, sudo, local, task


@task
def launch_prod():
	with cd('/var/www/glossify'):
		sudo("git reset --hard")
		sudo("git pull --all")
		sudo("cp /var/www/glossify/app/www/coffee/src/config-prod.coffee /var/www/glossify/app/www/coffee/src/config.coffee")
		with cd('/var/www/glossify/app/scripts'):
			sudo('./compile_coffee')
			sudo('./compile_less')
		sudo("cp -rf /home/ubuntu/Envs/tenk/lib/python2.7/site-packages /var/www/glossify/web")
		run("export WORKON_HOME=~/Envs")
		run("source /usr/local/bin/virtualenvwrapper.sh")
		sudo("pip install -r $HOME/work/glossify/web/requirements.txt")
		sudo("apachectl restart")


@task
def dump_mongo(*args):
	collections = list(args)
	out_dir = '/data/dump'
	sudo("mkdir -p %s" % out_dir)
	for collection in collections:
		sudo("mongodump --db tenk --collection %s --out %s" % (collection, out_dir))
