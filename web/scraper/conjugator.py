import json

conjugation_table = None
with open('/home/ubuntu/conjugation_table.json') as f_in:
	conjugation_table = json.load(f_in)

def get_all_forms(base, conj_type):
	return ["%s%s" % (base, conjugation_table[conj_type][form]) for form in conjugation_table[conj_type]]

print get_all_forms('con', 'fr-conj-3-naitre')