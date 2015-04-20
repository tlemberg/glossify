# -*- coding: utf-8 -*-

import re
import argparse
from os import listdir
from os.path import isfile, join
import json

parser = argparse.ArgumentParser()
parser.add_argument("filenameout")
args = parser.parse_args()

base_dir_in = '/data/wikidumps/templates'
filename_out = args.filenameout
f_out = open(filename_out, 'w')

h = {}

def iter_files(base_dir, f):
	for obj in listdir(base_dir):
		path = join(base_dir, obj)
		if isfile(path): f(path, obj)

def process_file(path, obj):
	if re.search(r'conj\-', path, re.UNICODE):
		h[obj] = {}
		with open(path) as f_in:
			for line in f_in:
				mapping = process_line(line)
				if mapping:
					h[obj][mapping['form']] = mapping['rule']


def process_line(line):
	m = re.search(r'\|([a-z|1-3|.]*?)=\{\{\{1\}\}\}(.*?)\|', line, re.UNICODE)
	if m:
		return {
			'form': m.group(1).strip(),
			'rule': m.group(2).strip()
		}

iter_files(base_dir_in, process_file)

json_string = json.dumps(h, sort_keys=True, indent=4, separators=(',', ': '), ensure_ascii=False)
f_out.write(json_string)