import os
from fabric.api import run

def launch_prod():
	script_path = os.path.join(os.environ['PROJECT_HOME'], 'launch_server')
	run("%s prod" % script_path)


def launch_prod():
	run('launch_server dev')