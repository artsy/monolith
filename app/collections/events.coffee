config       = require '../config/config'
Event        = require '../models/event'
Collection   = require '../core/collection'

module.exports = class Events extends Collection
  debugMode: env.DEBUG_MODE || true
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
      return models[Object.keys(models)[1]]
    else
      return @filter (model) ->
        moment(model.get('start_at')).utc().isSame new Date, 'day'


  groupByDate: ->
    if @models.length
      @groupBy (model) -> moment(model.get('start_at')).utc().format('YYYY-MM-DD')

  upcomingEvents: (quanity, unit)->
    now = moment().utc()
    future = moment().utc().add quanity, unit

    @find (model) ->
      moment(model.get('start_time')).utc().isBetween now, future, 'minute'