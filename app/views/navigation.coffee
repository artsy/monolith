View      = require '../core/view'
template  = require '../templates/navigation'
Loadable  = require '../utils/loadable'
Fairs     = require '../collections/fairs'

module.exports = class ScreensaverView extends View
  _.extend @prototype, Loadable

  id: 'navigation'
  template: template

  initialize: ->
    @fairs = new Fairs

    @listenTo @fairs, 'sync', @render
    @listenTo @fairs, 'sync', @loadingDone

    @fairs.fetch data: size: 60

  render: ->
    @$el.html @template(fairs: @fairs)
    this
