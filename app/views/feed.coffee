config    = require '../config/config'
View      = require '../core/view'
Queue     = require '../collections/queue'
Loadable  = require '../utils/loadable'
Entries   = require '../collections/entries'

template  = require '../templates/feed'

module.exports = class FeedView extends View
  _.extend @prototype, Loadable

  template: template
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

    @listenTo @entries, 'sync', @render
    @listenTo @entries, 'sync', @loadingDone

    @entries.fetch()

  render: ->
    @$el.html @template(entries: @entries)

    @setElementCaches()

    this

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
      }
    ]

    $.Velocity.RunSequence [sequence[0]]
    $.Velocity.RunSequence [sequence[1]]
    $.Velocity.RunSequence [sequence[2]]
    $.Velocity.RunSequence [sequence[3]]
    $.Velocity.RunSequence [sequence[4], sequence[5]]
