config          = require '../config/config'
View            = require '../core/view'
Queue           = require '../collections/queue'
Loadable        = require '../utils/loadable'
Entries         = require '../collections/entries'

frameTemplate   = require '../templates/feed'
entriesTemplate = require '../templates/feed_entries'

module.exports = class FeedView extends View
  _.extend @prototype, Loadable

  frameTemplate: frameTemplate
  entriesTemplate: entriesTemplate
  id: 'feed'
  animationDuration: 400

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
    @entries = new Entries

    @listenTo @entries, 'sync', @renderFrame
    @listenTo @entries, 'sync', @loadingDone

    @entries.fetch()

  renderFrame: =>
    @$el.html @frameTemplate()
    @renderEntries()
    @setElementCaches()

    this

  renderEntries: ->
    @$('#screen__entries').html @entriesTemplate entries: @entries

  onAnimationComplete: =>
    _.delay =>
      @entries.shift()
      if @entries.length
        @renderEntries()
      else
        @transitionToHoldingPage()

  transitionToHoldingPage: ->
    console.log 'transitioning to our holding page'

  runAnimation:->
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
          sequenceQueue: false
      },
      {
        e: @$('.screen--feed__entry.is-index_0')
        p:
          top: "#{@screenPadding}px"
          left: "#{@screenPadding}px"
          width: @largeImageSize
        options:
          duration: @animationDuration
          sequenceQueue: false
      },
      {
        e: @$('.screen--feed__entry.is-index_1')
        p:
          translateX: "-#{@smallImageSize}px"
          translateY: "-#{@smallImageSize}px"
        options:
          duration: @animationDuration
          sequenceQueue: false
      },
      {
        e: @$('.screen--feed__entry.is-index_2')
        p:
          translateX: "#{@smallImageSize}px"
          translateY: "-#{@smallImageSize}px"
        options:
          duration: @animationDuration
          sequenceQueue: false
      },
      {
        e: @$('.screen--feed__entry.is-index_3')
        p:
          translateX: "-#{@smallImageSize}px"
          translateY: "-#{@smallImageSize}px"
        options:
          duration: @animationDuration
          sequenceQueue: false
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
