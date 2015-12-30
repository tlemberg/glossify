from app.appconfig import app_instance
from app.views     import apiviews, managerviews, authviews, uploadviews

import os

if __name__ == '__main__':
	if not os.environ.get('ISLOCAL'):
		app_instance.run(host='0.0.0.0', port=int(os.environ['DEV_WEB_PORT']), debug=True, ssl_context=('../ssl/cert.pem','../ssl/key.pem'))
	else:
		app_instance.run(host='localhost', port=int(os.environ['DEV_WEB_PORT']), debug=True)
