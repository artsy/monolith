config    = require '../config/config'
View      = require '../core/view'
Feed      = require '../models/feed'
Queue     = require '../collections/queue'
MapUtils  = require '../utils/map'
Loadable  = require '../utils/loadable'

template      = require '../templates/map'
seenTemplate  = require '../templates/map/seen'

module.exports = class MapView extends View
  _.extend @prototype, Loadable

  id: 'map'
  stepInterval: 6000
  updateInterval: 30000
  transitionDuration: 1000
  template: template
  events:
    'click #debug-rotate'       : 'rotate'
    'click #debug-update'       : 'update'
    'click #debug-step'         : 'next'
    'click #debug-stop'         : 'stop'
    'click #debug-place-marker' : 'placeMarker'

  initialize: ->
    @feed   = new Feed
    @queue  = new Queue

  log: (payload) ->
    APP.log 'map', payload

  play: ->
    @__stepTimer__    = setInterval @STEP, @stepInterval
    @__updateTimer__  = setInterval @update, @updateInterval

  stop: ->
    clearInterval @__stepTimer__
    clearInterval @__updateTimer__

  placeMarker: ->
    @$('.you-are-here').remove()
    @$el.one 'click', (e) =>
      [x, y] = [e.pageX, e.pageY]
      @positionMarker x, y

  positionMarker: (x, y) ->
    window.localStorage.setItem 'position', "#{x}:#{y}"
    $marker = $('<div class="you-are-here"></div>').css transform: "translate(#{x}px, #{y}px)"
    @$el.append $marker

  checkForMarker: ->
    coordinates = window.localStorage.getItem 'position'
    if coordinates
      [x, y] = coordinates.split ':'
      @positionMarker x, y

  drawIndicators: ->
    @$map.find('.map-dot').attr 'data-state', 'inactive'
    # Wait for transition out
    _.delay =>
      @$map.html @queue.active.shows.map (show) =>
        @placeMapDot show
    , 1000

  # @return {jQuery}
  placeMapDot: (show) ->
    [x, y] = show.location()
    if x and y
      [x, y]  = MapUtils.toMap x, y, config.FAIR_ID
      $marker = $('<div class="map-dot" data-state="inactive"></div>').
        attr('data-id', show.get('partner').id).
        css(left: "#{x}px", bottom: "#{y}px")
      _.defer =>
        $marker.attr 'data-state', 'active'
      $marker

  renderActions: ($el, actions) ->
    $el.html(_.map actions, (action) ->
      $(action.get 'fragment')
    ).removeClass 'is-transitioning'

  STEP: =>
    renderQueue = @queue.STEP()

    if @hasMap
      @drawIndicators()

    # Delay such that markers come in after
    # and out slightly before content
    _.delay =>
      # Transition, then wait for the transition duration
      @$queue.addClass 'is-transitioning'
      _.delay =>
        # Re-renders 3 elements, active, and the two onDeck
        # The transition puts the previous view into the state
        # that the stepped re-rendered view should be in
        @renderActions @$queue, renderQueue
      , @transitionDuration

      # If there is no map then render seen
      unless @hasMap
        @$seen.addClass 'is-transitioning'
        _.delay =>
          @renderActions @$seen, @queue.seen
        , @transitionDuration
    , 500

  update: =>
    return if @updating
    @updating = true
    @feed.fetch
      data: size: 10
      success: (feed, response, xhr) =>
        @updating = false
        # Return if the feed hasnt been updated
        return if @feedUpdatedAt is response.updated_at
        @feedUpdatedAt = response.updated_at
        # Add new items to the queue at the insertIndex
        @queue.add response.items, parse: true, at: @queue.options.insertIndex
        # Fetch extend information (this needs to be wrapped into the insertion)
        @queue.fetchShows()
        @log "#{@queue.length} items in the queue"
      error: (model, response, options) =>
        @updating = false
        @log 'There was an error updating the feed'

  # Called once on view initialization
  bootstrap: ->
    @feed.fetch
      data: size: 40
      success: (feed, response, xhr) =>
        @feedUpdatedAt = response.updated_at
        @queue.add response.items, parse: true
        @queue.sort()
        @queue.fetchShows().always =>
          @STEP()
          @play()
          @loadingDone()
          @log 'Starting playback of map'

  handleResponse: (response, callback) ->
    actions = new Actions response.items, parse: true
    actions.fetchShows().then ->
      callback actions

  cacheSelectors: ->
    @$screen  = @$('#screen')
    @$map     = @$('#map-map')
    @$queue   = @$('#map-queue')

  setupMap: ->
    if @hasMap = MapUtils.hasMap config.FAIR_ID
      @$map.css backgroundImage: "url(images/maps/#{config.FAIR_ID}.png)"
      @checkForMarker()
    else
      @$map.remove()
      @$screen.append seenTemplate()
      @$seen = @$('#map-seen')

  postRender: ->
    @cacheSelectors()
    @setupMap()
    @bootstrap()

  render: ->
    @$el.html @template(queue: @queue)
    _.defer =>
      @postRender()
    this

  remove: ->
    @stop()
    super

  #
  # DEBUG
  #

  next: ->
    @stop()
    @STEP()

  rotate: ->
    @$screen.toggleClass 'is-rotated'
