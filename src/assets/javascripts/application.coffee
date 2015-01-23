Backbone    = require 'backbone'
Backbone.$  = require 'jquery'
Router      = require './routers/router'
config      = require './config/config'

module.exports =
  __name__: ->
    'monolith_' + Math.random().toString(36).substr 2, 9

  log: (name, payload) ->
    if @channels
      @channels.status.trigger "client-#{name}",
        client: @name
        data: payload

  setupMonitoring: ->
    @name = @__name__()

    @pusher = new Pusher process.env.PUSHER_KEY,
      authEndpoint: process.env.PUSHER_AUTH_ENDPOINT
      auth: params: client_id: @name

    @channels =
      command: @pusher.subscribe 'command'
      status: @pusher.subscribe "private-status_#{@name}"
      presence: @pusher.subscribe 'presence-status'

    @channels.command.bind 'restart', (name) =>
      if (name is @name) or (name is 'all')
        window.location.reload true

  authenticate: (options = {}) ->
    _sync = Backbone.sync
    Backbone.sync = (method, model, options) ->
      options.beforeSend = (xhr) ->
        xhr.setRequestHeader 'X-XAPP-TOKEN', process.env.XAPP_TOKEN
      _sync.apply this, arguments
    options.success()

  initialize: ->
    @authenticate
      success: =>
        @router = new Router()
        Backbone.history.start()
        if process.env.PUSHER_KEY and process.env.PUSHER_AUTH_ENDPOINT
          @setupMonitoring()
