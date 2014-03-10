benv              = require 'benv'
trendingResponse  = require '../fixtures/trending_partners'

describe 'Trend', ->
  beforeEach (done) ->
    benv.setup ->
      benv.expose
        $: benv.require 'jquery'
        _: benv.require 'underscore'
        Backbone: benv.require 'backbone'

      @Trending   = require '../../app/collections/trending'
      @Trend      = require '../../app/models/trend'

      done()

  afterEach (done) ->
    benv.teardown()
    done()

  describe '#initialize', ->
    it 'cannot be used without a collection', ->
      (-> new Trend()).should.throw()

  describe 'as part of a collection', ->
    beforeEach ->
      @trending = new Trending
      @trending.entity = 'partner'
      @trending.reset trendingResponse, parse: true
      @trend = @trending.first()

    it 'has an __entity__ set', ->
      @trend.__entity__.should.equal 'partner'

    it 'commits the scores it has to a history', ->
      scores = @trend.__scores__
      scores.should.be.an.instanceOf Array
      keys = _.keys scores[0]
      keys.should.include 'score'
      keys.should.include 'fair_partner_follow'
      keys.should.include 'fair_partner_inquiry'
      keys.should.include 'fair_partner_view'
      keys.should.include 'fair_partner_save'

    it 'initially has a difference of 0', ->
      @trend.get('difference').should.equal 0

    it 'returns a meaningful difference to display when the score is changed', ->
      @trend.set
        score: 16
        fair_partner_follow: (@trend.get('fair_partner_follow') + 1)
      @trend.get('difference').should.equal 1
      @trend.set
        score: 16.5
        fair_partner_follow: (@trend.get('fair_partner_follow') + 1)
        fair_partner_inquiry: (@trend.get('fair_partner_inquiry') + 1)
      @trend.get('difference').should.equal 2
      @trend.set
        score: 17
        fair_partner_follow: (@trend.get('fair_partner_follow') + 2)
        fair_partner_inquiry: (@trend.get('fair_partner_inquiry') + 0)
        fair_partner_save: (@trend.get('fair_partner_save') + 4)
      @trend.get('difference').should.equal 6
      @trend.set score: 18
      @trend.get('difference').should.equal 0
      @trend.set
        score: 19
        fair_partner_follow: (@trend.get('fair_partner_follow') + 2)
        fair_partner_inquiry: (@trend.get('fair_partner_inquiry') + 0)
        fair_partner_view: (@trend.get('fair_partner_view') + 4)
      @trend.get('difference').should.equal 6
      @trend.set 'score', 17
      @trend.get('difference').should.equal 0

    it 'should use a whitelist and ignore score', ->
      @trend.set
        score: 19
        fair_partner_save: (@trend.get('fair_partner_save') + 4)
      @trend.get('difference').should.equal 4

    it 'has access to the previous scores', ->
      @trend.previousScores().fair_partner_follow.should.equal 96
