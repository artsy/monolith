_         = require 'underscore'
View      = require '../core/view'
Loadable  = require '../utils/loadable'
Fairs     = require '../collections/fairs'

template  = -> JST["navigation"] arguments...

module.exports = class NavigationView extends View
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
