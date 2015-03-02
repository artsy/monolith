module.exports = class Router extends Backbone.Router

  initialize: ->
    @prevRoute = null
    @prevParams = []
    @route = null
    @params = []

    @on 'route', ( route, params ) ->
      @prevRoute = @route
      @prevParams = @params
      @route = route
      @params = params
