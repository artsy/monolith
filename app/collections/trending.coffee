config      = require '../config/config'
Collection  = require '../core/collection'
Trend       = require '../models/trend'

module.exports = class Trending extends Collection
  model: Trend

  comparator: (trend) ->
    -trend.get 'score'

  initialize: ->
    @on 'change:score', (model) =>
      difference = model.changed.score - model.previous('score')
      @trigger 'updated:score', model, difference

  fetchShows: ->
    dfd = $.Deferred()
    # Kill this if it takes too long.
    # We're only using it for images and can
    # fall back to profile icons
    delay = _.delay dfd.resolve, config.TIMEOUT
    $.when.apply(null, @map (trend) =>
      unless trend.get 'fetched'
        trend.entity.fetchShows
          success: (collection) ->
            trend.set 'fetched', true
    ).then ->
      clearInterval delay
      dfd.resolve()
    dfd.promise()
