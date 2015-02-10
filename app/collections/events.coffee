config       = require '../config/config'
Event        = require '../models/event'
Collection   = require '../core/collection'

module.exports = class Events extends Collection
  debugMode: true
  model: Event

  url: -> "#{config.API_ROOT}/fair/#{@fairId}/fair_events"

  initialize: (options)->
    @fairId = options.fairId
    @debugMode = options.debugMode || @debugMode

  currentEvents: ->
    unless @debugMode
      return @filter (model) ->
        moment(model.get('start_time')).isSame new Date, 'day'

    return @models

  upcomingEvents: (quanity, unit)->
    now = moment()
    future = moment().add quanity, unit

    @find (model) ->
      moment(model.get('start_time')).isBetween now, future, 'minute'