_         = require 'underscore'
Model     = require '../core/model'
Artist    = require './artist'
Partner   = require './partner'

module.exports = class Trend extends Model
  modelMap:
    'artist': Artist
    'partner': Partner

  initialize: ->
    throw 'Requires a collection' unless @collection

    @__scores__ = []
    @on 'change:score', @commitScores, this
    @commitScores()

  commitScores: ->
    @__scores__.push @scores()
    @difference()

  scores: ->
    _.pick(
      @attributes,
      'score',
      "fair_#{@__entity__}_follow",
      "fair_#{@__entity__}_inquiry",
      "fair_#{@__entity__}_view",
      "fair_#{@__entity__}_save"
    )

  difference: ->
    whitelist = _.pick(
      @previousScores(),
      "fair_#{@__entity__}_follow",
      "fair_#{@__entity__}_inquiry",
      "fair_#{@__entity__}_view",
      "fair_#{@__entity__}_save"
    )

    difference = _.reduce whitelist, (memo, v, k) =>
      memo += @attributes[k] - v
    , 0
    difference = Math.abs(Math.ceil(difference))
    @set 'difference', difference
    difference

  previousScores: ->
    @__scores__[@__scores__.length - 2] or @scores()

  parse: (response) ->
    @__entity__   ?= @collection.entity
    @entity       ?= new @modelMap[@collection.entity](response[@__entity__])
    delete response[@collection.entity]
    response
