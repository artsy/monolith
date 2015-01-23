_         = require 'underscore'
View      = require '../core/view'
template  = -> JST["screensaver"] arguments...


module.exports = class ScreensaverView extends View
  id: 'screensaver'
  template: template

  randomPosition: =>
    @$screen ?= @$('#screen')
    @$logo   ?= @$('#screensaver-logo')

    x   = Math.floor Math.random() * (@$screen.width() - @$logo.width())
    y   = Math.floor Math.random() * (@$screen.height() - @$logo.height())

    @$logo.css transform: "translate(#{x}px, #{y}px)"

  postRender: ->
    @randomPosition()
    @__updateTimer__ = setInterval @randomPosition, 10000

  render: ->
    @$el.html @template
    _.defer =>
      @postRender()
    this
