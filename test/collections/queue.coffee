benv          = require 'benv'
feedResponse  = require '../fixtures/feed'

describe 'Queue', ->
  beforeEach (done) ->
    benv.setup ->
      benv.expose
        $: benv.require 'jquery'
        _: benv.require 'underscore'
        Backbone: benv.require 'backbone'

      @Queue = benv.require '../../app/collections/queue'
      @Queue.__set__ 'actionTemplate', -> '<div>foobar</div>'

      @Action = require '../../app/models/action'

      done()

  afterEach (done) ->
    benv.teardown()
    done()

  describe 'defaults', ->
    it 'has them', ->
      @queue = new Queue
      @queue.options.insertIndex.should.equal 2
      @queue.options.maxLength.should.equal 100

    it 'they can be overwritten', ->
      @queue = new Queue null, insertIndex: 3, maxLength: 20
      @queue.options.insertIndex.should.equal 3
      @queue.options.maxLength.should.equal 20

  describe 'behavior', ->
    describe '#oldest', ->
      it 'returns the oldest item in the collection', ->
        @queue = new Queue _.shuffle(feedResponse.items)
        oldest = @queue.oldest()
        oldest.id.should.equal '53122997ebad6416c2000824'
        @queue.remove oldest
        oldest = @queue.oldest()
        oldest.id.should.equal '531229b8ebad6416c2000825'

    it 'enforces maxLength', ->
      @queue = new Queue null, maxLength: 5
      @queue.add _.first(feedResponse.items, 5)
      feedResponse.items.length.should.equal 10
      @queue.length.should.equal 5
      @queue.add _.last(feedResponse.items)
      @queue.length.should.equal 5
      # Doesn't always strictly enforce the length
      # If you're adding duplicates, it's going to be
      # pulling off oldest things first
      @queue.add feedResponse.items
      @queue.length.should.be.below 10

    describe '#guardedRender', ->
      it 'renders the action if the action is not rendered yet', ->
        action = new Action feedResponse.items[0]
        @queue.guardedRender [action]
        action.get('rendered').should.be.ok
        action.set 'fragment', 'canary'
        @queue.guardedRender [action]
        action.get('fragment').should.equal 'canary'

    describe '#__seen__', ->
      beforeEach ->
        # Simulate #STEP
        @active   = @queue.__step__()
        onDeck    = @queue.first @queue.options.insertIndex
        actions   = [@active].concat onDeck

        @fourthToLast   = @queue.at 5
        @thirdToLast    = @queue.at 6
        @secondToLast   = @queue.at 7
        @last           = @queue.last()
        @first          = @queue.first()

        @seen = @queue.__seen__ actions

      it 'gets an ordered window of the most recently seen actions', ->
        @seen[0].id.should.equal @first.id
        @seen[1].id.should.equal @last.id
        @seen[2].id.should.equal @secondToLast.id
        @seen[3].id.should.equal @thirdToLast.id
        @seen[4].id.should.equal @fourthToLast.id

      it 'renders every action if need be', ->
        _.every(_.map @seen, (action) -> action.get 'rendered').should.be.true

    describe '#__step__', ->
      it 'moves through the queue', ->
        first   = @queue.first()
        second  = @queue.at 1
        third   = @queue.at 2
        fourth  = @queue.at 3
        last    = @queue.last()

        @queue.__step__()

        @queue.first().should.equal second
        @queue.at(1).should.equal third
        @queue.last().should.equal first

        @queue.__step__()

        @queue.first().should.equal third
        @queue.at(1).should.equal fourth
        @queue.last().should.equal second
        @queue.at(@queue.length - 2).should.equal first

    describe '#STEP', ->
      it 'returns the first 3 items from the queue and renders them', ->
        first   = @queue.first()
        second  = @queue.at 1
        third   = @queue.at 2

        renderQueue = @queue.STEP()
        renderQueue.length.should.equal 3

        renderQueue[0].should.equal first
        renderQueue[1].should.equal second
        renderQueue[2].should.equal third

        renderQueue[0].get('rendered').should.be.ok
        renderQueue[0].get('fragment').should.equal '<div>foobar</div>'
