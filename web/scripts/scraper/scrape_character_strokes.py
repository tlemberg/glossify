#!/usr/bin/env python
# -*- coding: utf-8 -*-

import dbutils
import re
import scraper
import shutil
import urllib2


code_map = scraper.get_gb2312_hash()


################################################################################
# main
#
################################################################################
def main():
	for a1 in range(0xb, 0xf+1):
		for a2 in range(0x0, 0xf+1):
			for a3 in range(0xa, 0xf+1):
				for a4 in range(0x1, 0xf+1):
					gb2312_str = "%01x%01x%01x%01x" % (a1, a2, a3, a4)
					get_document(gb2312_str)


################################################################################
# get_document
#
################################################################################
def get_document(gb2312_str):

	target_url  = "http://lost-theory.org/ocrat/chargif/sod/%s.gif" % gb2312_str
	target_path = "/data/tmp/strokes/%s.gif" % gb2312_str

	print target_url
	print target_path
	
	try:
		req = urllib2.urlopen(target_url)
		with open(target_path, 'wb') as fp:
			shutil.copyfileobj(req, fp)
	except urllib2.HTTPError:
		pass

main()