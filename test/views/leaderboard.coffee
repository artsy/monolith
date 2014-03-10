_       = require 'underscore'
sinon   = require 'sinon'
benv    = require 'benv'
eco     = require 'eco'

{ resolve } = require 'path'

describe 'LeaderboardView', ->
  beforeEach (done) ->
    benv.setup ->
      benv.expose
        $: benv.require 'jquery'
        _: benv.require 'underscore'
        Backbone: benv.require 'backbone'

      Backbone.$ = $
      sinon.stub Backbone, 'sync'

      @LeaderboardView = require '../../app/views/leaderboard'
      @LeaderboardView::bootstrap = sinon.stub()

      done()

  afterEach (done) ->
    Backbone.sync.restore()
    benv.teardown()
    done()

  describe 'LeaderboardView', ->
    beforeEach (done) ->
      # Because we are deleting parts of the response when we parse trends
      # we need do a non-cached require here
      response = benv.require resolve(__dirname, '../fixtures/trending_partners.js')

      @view = new LeaderboardView
      @view.activeBoard = @view.boards.first()
      @view.activeBoard.trending.reset response, parse: true
      @view.render()
      @view.cacheSelectors()
      done()

    describe '#activeBoard', ->
      it 'returns the $selector for the activeBoard', ->
        @view.$activeBoard().length.should.be.ok
        @view.$activeBoard().data('id').should.equal @view.activeBoard.id

    describe '#activeTarget', ->
      it 'returns the $selector for the activeTarget', ->
        @view.$activeTarget().length.should.be.ok
        @view.$activeTarget().data('id').should.equal @view.activeBoard.id

    describe '#renderBoard', ->
      it 'renders the board', ->
        @view.renderBoard @view.activeBoard
        $values = @view.$activeBoard().find('.board-value')
        $values.length.should.equal @view.activeBoard.trending.length
        $values.first().data('id').
          should.equal @view.activeBoard.trending.first().entity.id
        $values.last().data('id').
          should.equal @view.activeBoard.trending.last().entity.id
