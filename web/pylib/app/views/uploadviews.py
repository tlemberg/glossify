import flask
import upload

from app.appconfig import mongo, app_instance

################################################################################
# upload_page
#
################################################################################
@app_instance.route('/upload', methods=['POST'])
def upload_page():
	print request.POST
