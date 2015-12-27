import pymongo


DEAFULT_BUF_SIZE = 10000
DEFAULT_MAX_BULK_SIZE = 100


################################################################################
# get_phrase_for_base
#
################################################################################
def DBConnect(host, user, passwd):
	connect_str = "mongodb://%s:%s@%s/tenk" % (user, passwd, host)
	print connect_str
	client = pymongo.MongoClient(connect_str)
	return client.tenk


################################################################################
# get_section_for_base
#
################################################################################
def get_section_for_phrase(db, phrase):
	base = phrase['base']
	lang = phrase['lang']
	section = db.sections.find_one({ 'base': base, 'lang': lang }, { "text": 1 })
	if section == None:
		section = db.sections.find_one({ 'base': base.title(), 'lang': lang }, { "text": 1 })
		if section == None:
			section = db.sections.find_one({ 'base': base.upper(), 'lang': lang }, { "text": 1 })

	return section


def chunk_list(xs, chunk_size):
	for i in xrange(0, len(xs), chunk_size):
		yield xs[i:i+chunk_size]


class DBWriteBuffer(object):

	def __init__(self, coll, buf_size=DEAFULT_BUF_SIZE):
		self.coll = coll
		self.buf = []
		self.buf_size = buf_size

	def append(self, document):
		self.buf.append(document)
		if len(self.buf) >= self.buf_size:
			self.flush()

	def flush(self):
		if len(self.buf):
			print "Writing %d documents" % len(self.buf)
			self.coll.insert(self.buf)
			self.buf = []


class DBUpdateBuffer(object):

	def __init__(self, coll, max_bulk_size=DEFAULT_MAX_BULK_SIZE):
		self.coll = coll
		self.bulk = coll.initialize_ordered_bulk_op()
		self.bulk_size = 0
		self.max_bulk_size = max_bulk_size

	def append(self, find_params, update_params, upsert=False):
		if upsert:
			self.bulk.find(find_params).upsert().update(update_params)
		else:
			self.bulk.find(find_params).update(update_params)
		self.bulk_size += 1
		if self.bulk_size >= self.max_bulk_size:
			self.flush()

	def flush(self):
		if self.bulk_size:
			print "Updating %d documents" % self.bulk_size
			self.bulk.execute()
			self.bulk = self.coll.initialize_ordered_bulk_op()
			self.bulk_size = 0

