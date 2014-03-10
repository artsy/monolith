Router            = require '../core/router'
application       = require '../application'
HomeView          = require '../views/home'
LeaderboardView   = require '../views/leaderboard'
MapView           = require '../views/map'

module.exports = class ApplicationRouter extends Router
  routes:
    ''            : 'home'
    'leaderboard' : 'leaderboard'
    'map'         : 'map'

  initialize: ->
    $(window).on 'keyup', @toggleCursor

  toggleCursor: (e) ->
    return unless e.which is 72
    $('body').toggleClass 'has-cursor-hidden'

  home: ->
    @__teardown__()
    @view = new HomeView
    $('body').html @view.render().$el

  leaderboard: ->
    @__teardown__()
    @view = new LeaderboardView
    $('body').html @view.render().$el

  map: ->
    @__teardown__()
    @view = new MapView
    $('body').html @view.render().$el

  __teardown__: ->
    @view?.remove()
