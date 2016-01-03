import json, os, requests
from multiprocessing.dummy import Pool as ThreadPool
import time
import threading

from functools import wraps

API_BASE_URL = 'https://www.googleapis.com/language/translate/v2'
API_KEY = os.environ['GOOGLE_API_KEY']


def rate_limited(max_per_second):
    """
    Decorator that make functions not be called faster than
    """
    lock = threading.Lock()
    min_interval = 1.0 / float(max_per_second)

    def decorate(func):
        last_time_called = [0.0]

        @wraps(func)
        def rate_limited_function(*args, **kwargs):
            lock.acquire()
            elapsed = time.clock() - last_time_called[0]
            left_to_wait = min_interval - elapsed

            if left_to_wait > 0:
                time.sleep(left_to_wait)

            lock.release()

            ret = func(*args, **kwargs)
            last_time_called[0] = time.clock()
            return ret

        return rate_limited_function

    return decorate


@rate_limited(30)
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


