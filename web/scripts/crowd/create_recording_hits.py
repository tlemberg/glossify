from boto.mturk.connection import MTurkConnection, ExternalQuestion
from scraperutils import DBConnect
from turk_utils import create_hit

# Connection details
ACCESS_ID  ='AKIAIWTACFNXOSZ732OA'
SECRET_KEY = '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'
HOST       = 'mechanicalturk.sandbox.amazonaws.com'

# Connect to Mongo
db = DBConnect()

# Connect to MTurk
conn = MTurkConnection(
	aws_access_key_id     = ACCESS_ID,
	aws_secret_access_key = SECRET_KEY,
	host                  = HOST
)

# Create a HIT
create_hit(db, conn,
	min_rank = 1,
	max_rank = 10,
)
