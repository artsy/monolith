exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.

  # Application build path.  Default is public
  #buildPath: ''

  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
      order:
        before: [
          'vendor/scripts/jquery-2.1.0.js',
          'vendor/scripts/underscore-1.6.0.js',
          'vendor/scripts/backbone-1.1.2.js',
          'vendor/scripts/imagesloaded.js'
        ]

    stylesheets:
      defaultExtension: 'styl'
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
      order:
        before: ['vendor/styles/normalize.css']

    templates:
      defaultExtension: 'eco'
      joinTo: 'javascripts/templates.js'

  minify: no

  paths:
    watched: ['app', 'vendor/scripts', 'vendor/styles']

  server:
    path: 'server.coffee'
    port: 3333
    base: '/'
    run: yes
