config   = require '../config/config'
View     = require '../core/view'
Loadable = require '../utils/loadable'
Events   = require '../collections/events'
template = require '../templates/schedule'

# temp raw json
schedule = require '../collections/fixtures/schedule'

module.exports = class ScheduleView extends View
  _.extend @prototype, Loadable

  template: template
  id: 'schedule'

  events:
    'click' : 'nextEvent'

  initialize: ->
    @collection = new Events schedule

    @render()

    console.log 'events', @collection

  nextEvent: -> console.log 'nothing yet'

  render: ->
    @$el.html @template events: @collection
    @loadingDone()

    this