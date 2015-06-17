#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pymongo import MongoClient

import dbutils
import os
import re
import scraper

import csv,codecs,cStringIO

class UTF8Recoder:
    def __init__(self, f, encoding):
        self.reader = codecs.getreader(encoding)(f)
    def __iter__(self):
        return self
    def next(self):
        return self.reader.next().encode("utf-8")

class UnicodeWriter:
    def __init__(self, f, dialect=csv.excel, encoding="utf-8-sig", **kwds):
        self.queue = cStringIO.StringIO()
        self.writer = csv.writer(self.queue, dialect=dialect, **kwds)
        self.stream = f
        self.encoder = codecs.getincrementalencoder(encoding)()
    def writerow(self, row):
        '''writerow(unicode) -> None
        This function takes a Unicode string and encodes it to the output.
        '''
        self.writer.writerow([s.encode("utf-8") for s in row])
        data = self.queue.getvalue()
        data = data.decode("utf-8")
        data = self.encoder.encode(data)
        self.stream.write(data)
        self.queue.truncate(0)

    def writerows(self, rows):
        for row in rows:
            self.writerow(row)

# Connect to the database and get a list of phrases
db = dbutils.DBConnect()

path = os.path.join(os.environ['PROJECT_HOME'], "web/templates/worksheets/zh.csv")
out_file = open(path, 'w')
writer = UnicodeWriter(out_file,quoting=csv.QUOTE_ALL)

count = 0
cursor = db.phrases_zh.find({ 'txs': {'$exists': 1 } }).limit(100)
total_count = cursor.count()
d = {}
for phrase in cursor:
	new_txs = scraper.get_viewable_txs(phrase)

	d_chunks = []
	for t in new_txs.keys():
		t_chunks = ["%d. %s" % (i+1, new_txs[t][i]) for i in range(0, min(2, len(new_txs[t])))]
		d_chunks.append("%s => %s" % (t, "  ".join(t_chunks)))
	def_str = ' | '.join(d_chunks)

	txt = ''
	row = None
	if 'pron' in phrase:
		row = [phrase['base'], phrase['pron'], def_str]
	else:
		row = [phrase['base'], '', def_str]

	writer.writerow(row)