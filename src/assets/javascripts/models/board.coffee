$           = require 'jquery'
Model       = require '../core/model'
Collection  = require '../core/collection'
Trending    = require '../collections/trending'

module.exports = class Board extends Model
  initialize: ->
    @trending = new Trending
    @trending.on 'updated:score', (model, difference) =>
      @set 'stale', true
      @trigger 'updated:score', this, model, difference

  update: ->
    dfd = $.Deferred()
    @trending.fetch
      success: =>
        if @trending.entity is 'partner'
          @trending.fetchShows().then dfd.resolve
        else
          dfd.resolve()
      error: dfd.resolve
    dfd.promise()
