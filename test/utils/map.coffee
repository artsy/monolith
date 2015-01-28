benv = require 'benv'

describe 'MapUtils', ->
  beforeEach (done) ->
    benv.setup ->
      benv.expose
        $: benv.require 'jquery'
        _: benv.require 'underscore'
        Backbone: benv.require 'backbone'

      @MapUtils   = require '../../app/utils/map'
      @points     = x: 0.5, y: 0.5

      done()

  afterEach (done) ->
    benv.teardown()
    done()

  describe '#hasMap', ->
    it 'returns true or false based on the presence of a map transformation', ->
      MapUtils.hasMap('the-armory-show-2014').should.be.true
      MapUtils.hasMap('art-brussels-2014').should.be.false

  describe '#availableMaps', ->
    it 'knows what maps are available', ->
      MapUtils.availableMaps().should.be.an.instanceOf Array
      MapUtils.availableMaps().should.containEql 'the-armory-show-2014'

  describe '#toMap', ->
    it 'delegates to an available map tranformation handler', ->
      delta = 0.001
      [x, y] = MapUtils.toMap 0.5, 0.5, 'the-armory-show-2014'
      x.should.be.approximately 537.959, delta
      y.should.be.approximately 441.125, delta

  describe '#rotate', ->
    describe 'rotates the x, y coordinates', ->
      beforeEach ->
        @delta = 0.00001
      it 'rotates 90 degrees', ->
        [x, y] = MapUtils.rotate 0, 0, points.x, points.y, 90
        x.should.be.approximately -points.x, @delta
        y.should.be.approximately  points.y, @delta
      it 'rotates 180 degrees', ->
        [x, y] = MapUtils.rotate 0, 0, points.x, points.y, 180
        x.should.be.approximately -points.x, @delta
        y.should.be.approximately -points.y, @delta
      it 'rotates 270 degrees', ->
        [x, y] = MapUtils.rotate 0, 0, points.x, points.y, 270
        x.should.be.approximately  points.x, @delta
        y.should.be.approximately -points.y, @delta
      it 'rotates 360 degrees', ->
        [x, y] = MapUtils.rotate 0, 0, points.x, points.y, 360
        x.should.be.approximately points.x, @delta
        y.should.be.approximately points.y, @delta

  describe '#translate', ->
    describe 'translates the coordinate positions', ->
      it '1, 1', ->
        [x, y] = MapUtils.translate points.x, points.y, 1, 1
        x.should.equal 1.5
        y.should.equal 1.5
      it '1.5, -1.5', ->
        [x, y] = MapUtils.translate points.x, points.y, 1.5, -1.5
        x.should.equal 2
        y.should.equal -1

  describe 'scale', ->
    it 'scales the coordinates a uniform amount', ->
      [x, y] = MapUtils.scale points.x, points.y, 2
      x.should.equal 1
      y.should.equal 1
    it 'scales the coordinates a disimilar amount', ->
      [x, y] = MapUtils.scale points.x, points.y, 2, 4
      x.should.equal 1
      y.should.equal 2
