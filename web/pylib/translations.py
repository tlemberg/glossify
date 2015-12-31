import json, os, requests
from multiprocessing.dummy import Pool as ThreadPool

API_BASE_URL = 'https://www.googleapis.com/language/translate/v2'
API_KEY = os.environ['GOOGLE_API_KEY']


def translate(q, source, target):
	payload = {
		'q': q,
		'source': source,
		'target': target,
		'key': API_KEY,
	}
	response = requests.get(API_BASE_URL, params=payload)
	try:
		obj = json.loads(response.content)
		if obj.get('error'):
			print response.content
			raise Exception("Failed to translate '%s' due to API error." % q)
		return obj['data']['translations'][0]['translatedText']
	except:
		print "Failed to translate '%s'" % q
		print response.content
		return None
	


def pooled_translate(qs, source, target, n_pools=3):
	pool = ThreadPool(n_pools)
	results = pool.map(lambda q: (q, translate(q, source, target)), qs)
	pool.close()
	pool.join()
	return {q: result for (q, result) in results}


