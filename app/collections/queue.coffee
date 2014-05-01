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

  guardedRender: (actions) ->
    _.map actions, (action) ->
      unless action.get 'rendered'
        html = actionTemplate action: action
        action.set fragment: html, rendered: true
      action

  # Displays a window of the most recently seen actions
  # for use in displaying without a map.
  #
  # Should be a real cursor solution
  # What if there is less than this many items in the queue?
  #
  # @param {Array}
  # @return {Array}
  __seen__: (actions) ->
    onDeck = _.first actions, 2
    # Calling uniq on this guards against a duplicated
    # Action being presented when called post __step__, which
    # is mutating the queue
    renderQueue = _.uniq @last(6).concat(onDeck)
    # Reverse because we're moving from L to R
    (@guardedRender renderQueue).reverse()

  # Silently pops off the first action and
  # moves it to the end of the queue
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
  # @return {Array} An array of the 3 actions to be displayed
  STEP: ->
    @active       = @__step__()
    @onDeck       = @first @options.insertIndex
    renderQueue   = [@active].concat @onDeck
    @seen         = @__seen__ renderQueue

    @guardedRender renderQueue

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
