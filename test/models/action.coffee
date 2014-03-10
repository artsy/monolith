benv          = require 'benv'
feedResponse  = require '../fixtures/feed'

describe 'Action', ->
  beforeEach (done) ->
    benv.setup ->
      benv.expose
        $: benv.require 'jquery'
        _: benv.require 'underscore'
        Backbone: benv.require 'backbone'

      @Action = require '../../app/models/action'

      done()

  afterEach (done) ->
    benv.teardown()
    done()

  describe 'initials', ->
    it 'returns initials for the user display name', ->
      # Using real data
      new Action(feedResponse.items[0]).initials().should.equal 'Y.Z.'
      new Action(feedResponse.items[2]).initials().should.equal 'J.D.M.'

      # Bad data
      _.isUndefined(new Action(user: name: '').initials()).should.be.ok
      _.isUndefined(new Action(user: {}).initials()).should.be.ok
      _.isUndefined(new Action().initials()).should.be.ok
      new Action(user: name: 'f  bar  ').initials().should.equal 'f.b.'

      # &c
      new Action(user: name: 'Foo').initials().should.equal 'F.'
      new Action(user: name: 'Foo Bar').initials().should.equal 'F.B.'
      new Action(user: name: 'Foo Bar Baz').initials().should.equal 'F.B.B.'
      new Action(user: name: 'Foo Bar Baz Qux').initials().should.equal 'F.B.B.Q.'

      # dB
      new Action(user: name: 'Daniel Doubrovkine').initials().should.equal '<span class="is-lowercase">d</span>B'
