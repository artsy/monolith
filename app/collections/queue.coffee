Collection      = require '../core/collection'
Action          = require '../models/action'
actionTemplate  = -> require('../templates/map/action') arguments...

module.exports = class Queue extends Collection
  model: Action
  comparator: 'created_at'

  defaults:
    insertIndex: 2
    maxLength: 100

  initialize: (models, options = {}) ->
    @options = _.defaults options, @defaults

    @on 'add', @prune

    super

  __step__: (options = {}) ->
    action = @remove @first(), silent: true
    @add action, at: @length, silent: true
    if action.get 'stale'
      @trigger 'stale'
    else
      action.set 'stale', true
    action

  # Mutates the state of the queue and
  # renders the HTML fragments
  #
  # @return {Array} An array of the 3 actions to be rendered
  STEP: ->
    @active   = @__step__()
    @onDeck   = @first @options.insertIndex

    _.map [@active].concat(@onDeck), (action) ->
      unless action.get 'rendered'
        html = actionTemplate action: action
        action.set fragment: $(html), rendered: true
      action

  oldest: ->
    @min (action) ->
      Date.parse(action.get 'created_at')

  prune: ->
    @remove @oldest() if @length > @options.maxLength

  fetchShows: ->
    dfd = $.Deferred()
    @trigger 'update:starting'
    $.when.apply(null, @map (action) =>
      unless action.get 'fetched'
        action.fetchShows
          success: (collection) =>
            @trigger 'update:progress', collection
            action.set 'fetched', true
          error: =>
            # Todo - should remove the item from the queue
    ).then =>
      @trigger 'update:complete'
      dfd.resolve()
