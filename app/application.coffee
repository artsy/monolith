Router  = require 'routers/router'
config  = require 'config/config'

module.exports =
  __name__: ->
    'monolith_' + env.CLIENT_IP

  log: (name, payload) ->
    if @channels
      @channels.status.trigger "client-#{name}",
        client: @name
        data: payload

  setupEmoji: ->
    emoji.sheet_path = '../images/sheet_64.png'
    emoji.use_sheet = true
    emoji.init_env()

  setupMonitoring: ->
    @name = @__name__()

    @pusher = new Pusher env.PUSHER_KEY,
      authEndpoint: env.PUSHER_AUTH_ENDPOINT
      auth: params: client_id: @name

    @channels =
      command: @pusher.subscribe 'command'
      status: @pusher.subscribe "private-status_#{@name}"
      presence: @pusher.subscribe 'presence-status'

    @channels.command.bind 'restart', (name) =>
      if (name is @name) or (name is 'all')
        window.location.reload true

    @channels.command.bind 'route', (params) =>
      { name, route } = params

      if (name is @name) or (name is 'all')
        @router.navigate "#{config.FAIR_ID}/#{route}", trigger: true

  setupRouterChannels: ->
    Backbone.history.on 'route', (self, route, params)=>
      @pusher.unsubscribe "presence-status-#{@router.prevRoute}" if @router.prevRoute
      @pusher.subscribe "presence-status-#{route}"

  authenticate: (options = {}) ->
    _sync = Backbone.sync
    Backbone.sync = (method, model, options) ->
      options.beforeSend = (xhr) ->
        xhr.setRequestHeader 'X-XAPP-TOKEN', env.XAPP_TOKEN
      _sync.apply this, arguments
    options.success()

  initialize: ->
    @authenticate
      success: =>
        @router = new Router

        if env.PUSHER_KEY and env.PUSHER_AUTH_ENDPOINT
          @setupMonitoring()
          @setupRouterChannels()

        Backbone.history.start pushState: true

        @setupEmoji()
