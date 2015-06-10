from app.appconfig import app_instance
from app.views     import apiviews, managerviews, authviews, uploadviews

if __name__ == '__main__':
	app_instance.run(host='0.0.0.0', debug=True, ssl_context=('/etc/apache2/ssl/crt/vhost1.crt','/etc/apache2/ssl/key/vhost1.key'))
