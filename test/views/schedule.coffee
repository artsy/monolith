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
        env: {}

      Backbone.$ = $
      sinon.stub Backbone, 'sync'

      @marked = sinon.stub()
      @marked.Renderer = sinon.stub()
      @marked.setOptions = sinon.stub()

      @ScheduleView = require '../../app/views/schedule'
      @ScheduleView::initialize = sinon.stub()

      @Events = require '../../app/collections/events'

    # sets the clock to 16 minutes before first fake event
    @clock = sinon.useFakeTimers(1423154820000)

    done()

  afterEach (done) ->
    Backbone.sync.restore()
    @clock.restore()
    benv.teardown false
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
        @view.collection.models[0].set 'start_time', moment().add '2', 'minutes'
        @view.startScheduleCheck()
        @showSpy.called.should.not.be.ok

        # tick clock three minutes
        @clock.tick 10800

        @showSpy.called.should.be.ok
        @showSpy.calledWith @view.collection.models[0], @view.alerts[1]

