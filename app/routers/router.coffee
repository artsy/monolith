Router            = require '../core/router'
application       = require '../application'
HomeView          = require '../views/home'
LeaderboardView   = require '../views/leaderboard'
MapView           = require '../views/map'
config            = require 'config/config'

module.exports = class ApplicationRouter extends Router
  routes:
    ''                : 'home'
    ':id/leaderboard' : 'leaderboard'
    ':id/map'         : 'map'

  initialize: ->
    $(window).on 'keyup', @toggleCursor

  execute: ->
    @view?.remove()
    super

  toggleCursor: (e) ->
    return unless e.which is 72
    $('body').toggleClass 'has-cursor-hidden'

  home: ->
    @view = new HomeView
    $('body').html @view.render().$el

  leaderboard: (id) ->
    config.FAIR_ID = id
    @view = new LeaderboardView
    $('body').html @view.render().$el

  map: (id) ->
    config.FAIR_ID = id
    @view = new MapView
    $('body').html @view.render().$el
