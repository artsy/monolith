_       = require 'underscore'
sinon   = require 'sinon'
benv    = require 'benv'
eco     = require 'eco'

{ resolve } = require 'path'

describe 'ScheduleView', ->
  beforeEach (done) ->
    benv.setup ->
      benv.expose
        $: benv.require 'jquery'
        _: benv.require 'underscore'
        Backbone: benv.require 'backbone'
        moment: benv.require 'moment'

      Backbone.$ = $
      sinon.stub Backbone, 'sync'

      @marked = sinon.stub()
      @marked.Renderer = sinon.stub()
      @marked.setOptions = sinon.stub()

      @ScheduleView = require '../../app/views/schedule'
      @ScheduleView::initialize = sinon.stub()

      @Events = require '../../app/collections/events'

    # sets the clock to 16 minutes before first fake event
    @clock = sinon.useFakeTimers(new Date(2015, 1, 5, 11, 43).getTime())
    sinon.stub _, 'delay', (cab) -> cab()

    done()

  afterEach (done) ->
    Backbone.sync.restore()
    _.delay.restore()
    @clock.restore()
    benv.teardown()
    done()

  describe 'ScheduleView', ->
    beforeEach (done) ->
      @schedule = benv.require resolve(__dirname, '../../app/collections/fixtures/schedule.js')

      @view = new ScheduleView
      @view.collection = new Events @schedule

      @alertSpy = sinon.spy @view, 'maybeShowAlert'
      @showSpy = sinon.spy @view, 'showAlert'

      done()

    describe '#startScheduleCheck', ->
      it 'shows alert after scheduleCheckInterval is elapsed', ->
        @view.startScheduleCheck()
        @alertSpy.called.should.not.be.ok
        @clock.tick @view.scheduleCheckInterval
        @alertSpy.called.should.be.ok

    describe '#showAlert', ->
      it 'shows alert for The Cabbie Biennial when it is within range', ->
        @view.startScheduleCheck()
        @showSpy.called.should.not.be.ok

        # tick clock three minutes
        @clock.tick 180000

        @showSpy.called.should.be.ok
        @showSpy.calledWith @view.collection.models[0], @view.alerts[1]

