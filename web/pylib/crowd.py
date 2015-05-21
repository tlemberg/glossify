from boto.mturk.connection import MTurkConnection, ExternalQuestion


################################################################################
# MTurk constants
#
################################################################################
URL_BASE     = 'http://52.10.65.123:5000/task'
FRAME_HEIGHT = 600
KEYWORDS     = ['translate', 'translation', 'voice', 'audio', 'recording', 'english']
DURATION     = 60 * 5,
REWARD       = 0.01


################################################################################
# create_recording_hit
#
################################################################################
def create_hit(db, conn, hit_type, min_rank, max_rank):

	# Store the task in the DB
	task_id = db.tasks.insert({
		'hit_type': hit_type,
		'min_rank': min_rank,
		'max_rank': max_rank,
	})

	# Create the question, linking to the newly generated task_id
	task_url = "%s/%s" % (URL_BASE, task_id)
	question = ExternalQuestion(external_url, FRAME_HEIGHT)

	# Add the question to a singleton form
	question_form = QuestionForm()
	question_form.append(question)

	# Create the HIT
	conn.create_hit(
		questions       = question_form,
		max_assignments = 1,
		title           = 
		description     = 
		keywords        = KEYWORDS,
		duration        = DURATION,
		reward          = REWARD,
	)

