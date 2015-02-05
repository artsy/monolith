config   = require '../config/config'
View     = require '../core/view'
Loadable = require '../utils/loadable'
Events   = require '../collections/events'
template = require '../templates/schedule'
alert    = require '../templates/alert'

# temp raw json
schedule = require '../collections/fixtures/schedule'

module.exports = class ScheduleView extends View
  _.extend @prototype, Loadable

  template: template
  id: 'schedule'
  autoPlay: 6000
  scheduleCheckInterval: 30000
  alertDuration: 30000

  initialize: ->
    @collection = new Events schedule

  setupSlideshow: ->
    @slideshow = new Flickity '#events_slider',
      cellAlign: 'left'
      contain: true
      prevNextButtons: false
      wrapAround: true
      autoPlay: @autoPlay

    @slideshow.on 'select', @slideMiniSchedule

  slideMiniSchedule: =>
    $settledItem = @$('.events__details__item.is-selected')

    $(".events__mini-schedule__item.is-selected").removeClass 'is-selected'
    $(".events__mini-schedule__item[data-id='#{$settledItem.data('id')}']").addClass 'is-selected'

  startScheduleCheck: ->
    @scheduleInterval = setInterval @maybeShowAlert, @scheduleCheckInterval

  maybeShowAlert: =>
    events = @collection.upcomingEvents()

    console.log 'upcomingEvents', events

  render: ->
    @$el.html @template events: @collection.currentEvents()
    @loadingDone()
    _.delay =>
      @setupSlideshow()
      @startScheduleCheck()

    this