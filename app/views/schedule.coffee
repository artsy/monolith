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
  alert: alert
  id: 'schedule'
  autoPlay: 2000
  scheduleCheckInterval: 10000
  alertDuration: 3000
  alerts:[
    {
      count: 1
      unit: 'minutes'
    },
    {
      count: 15
      unit: 'minutes'
    }
  ]

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
    @scheduleInterval = setInterval =>
      @maybeShowAlert()
    , @scheduleCheckInterval

  maybeShowAlert: =>
    _.each @alerts, (alert) =>
      _event = @collection.upcomingEvents alert.count, alert.unit
      if _event and _event.get('alert') isnt alert.count
        return @showAlert(_event, alert)

  showAlert: (_event, alert)=>
    _event.set 'alert', alert.count
    @$('#screen__alert').html(@alert item: _event).addClass 'is-active'

    setTimeout ->
      $('#screen__alert').removeClass('is-active')
    , @alertDuration

  render: ->
    @$el.html @template events: @collection.currentEvents()
    @loadingDone()

    _.delay =>
      @setupSlideshow()
      @startScheduleCheck()

    this