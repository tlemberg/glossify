import hjson, json, os, re


def read_all_tag_files():
	tags = {}
	search_dir = os.path.join(os.environ['PROJECT_HOME'], 'files/tags')
	for file_name in os.listdir(search_dir):
		m = re.search('^(.*).hjson', file_name)
		if m:
			tag_name = m.group(1)
			tags[tag_name] = read_tag_file(os.path.join(search_dir, file_name))
	return tags

def read_tag_file(path):
	with open(path) as f:
		return json.loads(json.dumps(hjson.loads(f.read())))