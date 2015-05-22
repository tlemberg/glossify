################################################################################
# json_result
#
################################################################################
def json_result(obj):
	return JSONEncoder().encode(obj)


################################################################################
# hashify
#
################################################################################
def hashify(xs):
	r = {}
	for x in xs:
		r[x] = 1
	return r


################################################################################
# reverse_hash
#
################################################################################
def reverse_hash(h):
	r = {}
	for k, v in h.iteritems():
		r[v] = k
	return r


################################################################################
# compare_caseless
#
################################################################################
def compare_caseless(s1, s2):
	return s1.lower() == s2.lower()

