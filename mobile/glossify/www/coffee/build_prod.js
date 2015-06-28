({
	baseUrl: '/var/www/glossify/app/coffee/lib',
	out: '/var/www/glossify/app/coffee/build/main.js',
	include: ['app'],
	wrap: true,
	paths: {
		jquery: '../../js/jquery-2.1.3.min',
		hbs: '../../require-handlebars-plugin/hbs',
	}
})