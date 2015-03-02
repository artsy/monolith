Router            = require '../core/router'
application       = require '../application'
ScreensaverView   = require '../views/screensaver'
LeaderboardView   = require '../views/leaderboard'
MapView           = require '../views/map'
FeedView          = require '../views/feed'
ScheduleView      = require '../views/schedule'
NavigationView    = require '../views/navigation'
config            = require 'config/config'

module.exports = class ApplicationRouter extends Router
  routes:
    ''                : 'navigation'
    'screensaver'     : 'screensaver'
    ':id/leaderboard' : 'leaderboard'
    ':id/map'         : 'map'
    ':id/feed'        : 'feed'
    ':id/schedule'    : 'schedule'

  initialize: ->
    super
    @$body = $('body')

    $(window).on 'keyup', @__toggleCursor__

  execute: ->
    @view?.remove()
    super

  __toggleCursor__: (e) ->
    return unless e.which is 72
    @$body.toggleClass 'has-cursor-hidden'

  __render__: ->
    @$body.html @view.render().$el

  navigation: ->
    @view = new NavigationView
    @__render__()

  screensaver: ->
    @view = new ScreensaverView
    @__render__()

  leaderboard: (id) ->
    config.FAIR_ID = id
    @view = new LeaderboardView
    @__render__()

  map: (id) ->
    config.FAIR_ID = id
    @view = new MapView
    @__render__()

  feed: (id) ->
    config.FAIR_ID = id
    @view = new FeedView
    @__render__()

  schedule: (id) ->
    config.FAIR_ID = id
    @view = new ScheduleView
    @__render__()
