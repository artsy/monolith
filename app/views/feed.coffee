config          = require '../config/config'
View            = require '../core/view'
Queue           = require '../collections/queue'
Loadable        = require '../utils/loadable'
Entries         = require '../collections/entries'
Tags            = require '../collections/tags'

frameTemplate   = require '../templates/feed'
entriesTemplate = require '../templates/feed_entries'

module.exports = class FeedView extends View
  _.extend @prototype, Loadable

  frameTemplate: frameTemplate
  entriesTemplate: entriesTemplate
  id: 'feed'
  animationDuration: 800
  slideDuration: 10000

  events:
    'click' : 'runAnimation'

  setElementCaches: ->
    @$screen = @$('#screen')
    @screenPadding = parseInt @$screen.css('padding')
    @screenWidth = @$('#screen').outerWidth()
    @screenHeight = @$('#screen').outerHeight()
    @largeImageSize = @$('.screen--feed__entry.is-large .screen--feed__entry__image').outerWidth()
    @smallImageSize = @$('.screen--feed__entry.is-index_0 .screen--feed__entry__image').outerWidth()

  initialize: ->
    @tags = new Tags
    @entries = new Entries

    @listenTo @entries, 'sync', @renderFrame, @
    @listenTo @entries, 'sync', @loadingDone, @
    @listenToOnce @tags, 'sync', @fetchEntries, @

    @tags.fetch()

  fetchEntries: =>
    @entries.fetch
      reset: true
      error: =>
        @entries.reset @old_models
        @entries.trigger 'sync'

  renderFrame: =>
    @$el.html @frameTemplate tags: @tags
    @renderEntries()
    @setElementCaches()

    @interval = setInterval @runAnimation, @slideDuration

    @old_models = _.clone @entries.models

    this

  renderEntries: ->
    @$('#screen__entries').html @entriesTemplate entries: @entries

  onAnimationComplete: =>
    _.delay => @renderEntries() if @entries.length

  maybeShowHolder: =>
    @entries.shift()
    @transitionToHoldingPage() if not @entries.length

  transitionToHoldingPage: =>
    clearInterval @interval

    @$('#holding').velocity {opacity: 1}, {display: 'block', duration: @animationDuration}
    @$('.holding-inner').velocity {top: '740px'}, {delay: @animationDuration, duration: @animationDuration}
    setTimeout @fetchEntries, @slideDuration

  runAnimation: =>
    # get the size of the top element so we can move it offscreen
    $current = @$('.screen--feed__entry.is-large')
    $currentInfo = @$('.screen--feed__entry.is-large .screen--feed__entry__info')
    current_top = $current.outerHeight() + @screenPadding + $currentInfo.outerHeight()

    sequence = [
      {
        e: $current
        p: top: "-#{current_top}px"
        options:
          duration: @animationDuration
          complete: @maybeShowHolder
      },
      {
        e: @$('.screen--feed__entry.is-index_0')
        p:
          top: "#{@screenPadding}px"
          left: "#{@screenPadding}px"
          width: @largeImageSize
        options:
          duration: @animationDuration
      },
      {
        e: @$('.screen--feed__entry.is-index_1')
        p:
          translateX: "-#{@smallImageSize}px"
          translateY: "-#{@smallImageSize}px"
          translateZ: 0
          scale: 1
        options:
          duration: @animationDuration
      },
      {
        e: @$('.screen--feed__entry.is-index_2')
        p:
          translateX: "#{@smallImageSize}px"
          translateY: "-#{@smallImageSize}px"
          translateZ: 0
          scale: 1
        options:
          duration: @animationDuration
      },
      {
        e: @$('.screen--feed__entry.is-index_3')
        p:
          translateX: "-#{@smallImageSize}px"
          translateY: "-#{@smallImageSize}px"
          translateZ: 0
          scale: 1
        options:
          duration: @animationDuration
      },
      {
        e: @$('.screen--feed__entry.is-index_0 .screen--feed__entry__info')
        p:
          opacity: "1"
        options:
          display: "block"
          duration: @animationDuration
          complete: @onAnimationComplete
      }
    ]

    $.Velocity.RunSequence [sequence[0]]
    $.Velocity.RunSequence [sequence[1], sequence[5]]
    $.Velocity.RunSequence [sequence[2]]
    $.Velocity.RunSequence [sequence[3]]
    $.Velocity.RunSequence [sequence[4]]
