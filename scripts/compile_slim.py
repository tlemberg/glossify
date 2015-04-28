#!/usr/bin/env python

import os
import commands

project_home = os.environ['PROJECT_HOME']
slim_home    = "%s/app/www/slim" % project_home

app_file = "%s/src/app.slim" % slim_home
pages_dir = "%s/src/pages" % slim_home

app_slim = ''
with open(app_file, 'r') as f:
    app_slim = f.read()

page_slim_list = []
for file_name in os.listdir(pages_dir):
	page_file = os.path.join(pages_dir, file_name)
	with open(page_file, 'r') as f:
		page_slim_list.append(f.read())

indented_pages = ["\t\t%s" % html.replace("\n", "\n\t\t") for html in page_slim_list]

combined_slim = app_slim + "\n" + '\n'.join(indented_pages)

tmp_file = "%s/src/tmp.slim" % slim_home
with open(tmp_file, 'w') as f:
	f.write(combined_slim)

html_file = "%s/lib/app.html" % slim_home

os.system("slimrb %s > %s" % (tmp_file, html_file))
os.system("rm %s" % tmp_file)