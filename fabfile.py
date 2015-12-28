import os
from fabric.api import run, cd, sudo, local

def launch_prod():
	with cd('/var/www/prod/glossify'):
		sudo("git fetch --all")
		sudo("git reset --hard")
		sudo("apachectl restart")


def launch_local():
	script_path = os.path.join(os.environ['PROJECT_HOME'], 'web/main.py')
	local("workon glossify")
	local("python %s" % script_path)
		
