from app.appconfig import app_instance
from app.views     import apiviews, managerviews, authviews, uploadviews

import os

if __name__ == '__main__':
	host = '0.0.0.0' if not os.environ.get('ISLOCAL') else 'localhost'
	app_instance.run(host=host, port=int(os.environ['DEV_WEB_PORT']), debug=True, ssl_context=('../ssl/cert.pem','../ssl/key.pem'))
