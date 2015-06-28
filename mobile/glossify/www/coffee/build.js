({
	baseUrl: 'lib',
	out: 'build/main.js',
	include: ['app'],
	wrap: true,
	paths: {
		jquery: '../../js/jquery-2.1.3.min',
		hbs: '../../require-handlebars-plugin/hbs',
	}
})