from app.appconfig import app_instance
from app.views     import apiviews, managerviews, authviews, uploadviews

import os

if __name__ == '__main__':
	app_instance.run(host='0.0.0.0', port=int(os.environ['DEV_WEB_PORT']), debug=True, ssl_context=('../ssl/cert.pem','../ssl/key.pem'))
