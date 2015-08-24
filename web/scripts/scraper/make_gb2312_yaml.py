import os
import re
import yaml


path_in = os.path.join(os.environ['PROJECT_HOME'], 'web/gb2312.txt')
path_out = os.path.join(os.environ['PROJECT_HOME'], 'web/gb2312.yaml')

code_map = {}

for line in open(path_in) :
	line = line.rstrip('\n')
	m = re.search(r'(.*?)=>(.*?),', line)
	if m:
		utf8_str   = str(m.group(1)).lower()
		gb2312_str = str(m.group(2)).lower()
		code_map[utf8_str] = gb2312_str

with open(path_out, 'w') as out_f:
	out_f.write(yaml.dump(code_map, default_flow_style=False, indent=2))
