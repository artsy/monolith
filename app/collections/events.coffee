config       = require '../config/config'
Event        = require '../models/event'
Collection   = require '../core/collection'

module.exports = class Events extends Collection
  debugMode: true
  model: Event

  url: -> "#{config.API_ROOT}/fair/#{@fairId}/fair_events"

  comparator: (model)->
    new Date model.get('start_at')

  initialize: (models, options)->
    @fairId = options?.fairId
    @debugMode = options?.debugMode || @debugMode

  currentEvents: ->
    if @debugMode
      models = @groupByDate()
      return models[Object.keys(models)[0]]
    else
      return @filter (model) ->
        moment(model.get('start_at')).isSame new Date, 'day'


  groupByDate: ->
    @groupBy (model) -> moment(model.get('start_at')).format('YYYY-MM-DD')

  upcomingEvents: (quanity, unit)->
    now = moment()
    future = moment().add quanity, unit

    @find (model) ->
      moment(model.get('start_time')).isBetween now, future, 'minute'