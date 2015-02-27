config   = require '../config/config'
View     = require '../core/view'
Loadable = require '../utils/loadable'
Events   = require '../collections/events'
Videos   = require '../collections/videos'
template = require '../templates/schedule'
alert    = require '../templates/alert'

# temp raw json
schedule = require '../collections/fixtures/schedule'

module.exports = class ScheduleView extends View
  _.extend @prototype, Loadable

  template: template
  alert: alert
  id: 'schedule'
  autoPlay: 2500
  scheduleCheckInterval: 10000
  alertDuration: 30000
  videoFade: 1000
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

  videos: [
    {
      id: 'follow'
      url: 'https://s3.amazonaws.com/artsy-columns/media/ArmoryBumper_FollowArtists_02_small.mp4'
    },
    {
      id: 'find'
      url: 'https://s3.amazonaws.com/artsy-columns/media/ArmoryBumper_FindExhibitors_02_small.mp4'
    },
    {
      id: 'favorite'
      url: 'https://s3.amazonaws.com/artsy-columns/media/ArmoryBumper_FavoriteWorks_02_small.mp4'
    }
  ]

  initialize: ->
    @collection = new Events {}, fairId: config.FAIR_ID
    @collection.fetch data: size: 30

    @collection.on 'sync', @postRender, @
    @collection.on 'sync', @loadingDone, @

    @videos = new Videos @videos
    @videos.on 'video:almostDone', @resumeSlideshow

  setupSlideshow: ->
    @slideshow = new Flickity '#events_slider',
      cellAlign: 'left'
      contain: true
      prevNextButtons: false
      wrapAround: true
      autoPlay: @autoPlay

    @slideshow.on 'cellSelect', @maybeslideMiniSchedule

  maybeslideMiniSchedule: =>
    $settledItem = @$('.events__details__item.is-selected')
    $(".events__mini-schedule__item.is-selected").removeClass 'is-selected'
    $(".events__mini-schedule__item[data-id='#{$settledItem.data('id')}']").addClass 'is-selected'

    if @slideshow.selectedIndex is 0
      @slideshow.player.pause()
      return setTimeout (=> @playBumper()), 1500

  playBumper: =>
    @$vidContainer.addClass 'is-active'
    @$vidContainer.find('video').hide()
    video = @videos.getNext()
    video.$el().
      addClass('is-active').
      fadeIn @videoFade, =>
        video.source().play()

  resumeSlideshow: =>
    @$('video.is-active').removeClass('is-active').
      fadeOut @videoFade, =>
        @$vidContainer.removeClass 'is-active'
        @slideshow.player.play()

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
    @$el.html @template
      events: @collection.currentEvents()
      videos: @videos

    this

  postRender: ->
    @render()

    @$vidContainer = @$('#screen__videos')

    # set up stuff that depends on fetching events
    _.delay =>
      @videos.bindEvents()
      @setupSlideshow()
      @startScheduleCheck()
