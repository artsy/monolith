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

  events:
    'click' : 'runAnimation'

  initialize: ->
    @entries = new Entries

    @listenTo @entries, 'sync', @render
    @listenTo @entries, 'sync', @loadingDone

    @entries.fetch()

  runAnimation: ->
    @$('.screen--feed__entry').addClass 'is-transitioning'

  render: ->
    @$el.html @template(entries: @entries)

    this
