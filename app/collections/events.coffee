config       = require '../config/config'
Event        = require '../models/event'
Collection   = require '../core/collection'

module.exports = class Events extends Collection
  debugMode: true
  model: Event

  url: -> "#{env.EUROPA_ENDPOINT}/api/events"

  currentEvents: ->
    unless @debugMode
      return @filter (model) ->
        moment(model.get('start_time')).isSame new Date, 'day'

    return @models