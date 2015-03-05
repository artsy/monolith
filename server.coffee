express = require 'express'
ECT = require 'ect'
{ resolve } = require 'path'

app = express()

ectRenderer = ECT watch: true, root: __dirname + '/views'
app.engine '.ect', ectRenderer.render

app.use express.static resolve __dirname, './public'

app.use require('artsy-xapp-middleware')
  artsyUrl: 'http://artsy.net'
  clientId: process.env.CLIENT_ID
  clientSecret: process.env.CLIENT_SECRET

app.get ['/', '/*'], (req, res) ->
  res.render 'index.ect',
    userAgent: req.get('user-agent')
    env:
      XAPP_TOKEN: res.locals.artsyXappToken
      PUSHER_KEY: process.env.PUSHER_KEY
      PUSHER_AUTH_ENDPOINT: process.env.PUSHER_AUTH_ENDPOINT
      EUROPA_ENDPOINT: process.env.EUROPA_ENDPOINT
      DEBUG_MODE: process.env.DEBUG_MODE
      CLIENT_IP: req.header('x-forwarded-for') || req.connection.remoteAddress

exports.startServer = (port, path, callback) ->
  app.listen port
  console.log "Listening on port: #{port}"
  callback?()
