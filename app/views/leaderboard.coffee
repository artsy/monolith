View            = require '../core/view'
Boards          = require '../collections/boards'
Board           = require '../models/board'
template        = require '../templates/leaderboard'
boardTemplate   = require '../templates/leaderboard/board'
Loadable        = require '../utils/loadable'

{ TrendingArtists, TrendingExhibitors, FollowedExhibitors } = require '../models/boards'

module.exports = class LeaderboardView extends View
  _.extend @prototype, Loadable

  id: 'leaderboard'
  template: template
  stepInterval: 8000
  updateInterval: 24000
  transitionDuration: 1000
  attributes:
    'data-page': 1

  events:
    'click #debug-rotate' : 'rotate'
    'click #debug-next'   : 'next'
    'click #debug-stop'   : 'stop'
    'click #debug-update' : 'update'
    'click #debug-render' : 'reRenderActiveBoard'

  initialize: (options) ->
    @boards = new Boards [
      new TrendingExhibitors
      new TrendingArtists
      new FollowedExhibitors
    ]

    @boards.each (board) =>
      @listenTo board, 'updated:score', @logBoardUpdate, this

  log: (payload) ->
    APP.log 'leaderboard', payload

  play: ->
    @__stepTimer__ = setInterval @STEP, @stepInterval

  stop: ->
    clearInterval @__stepTimer__

  updateBoard: (board) ->
    board.update()

  STEP: =>
    @boards.next()
    @activeBoard        = @boards.active()
    @activeBoardIndex   = @boards.indexOf @activeBoard

    # Set page
    @$el.attr 'data-page', @activeBoardIndex + 1

    # Move boards
    percentage = (100 / @boards.length) * @activeBoardIndex
    @$rail.css transform: "translateY(-#{percentage}%)"

    # Change title
    @$name.attr 'data-state', 'fade-out'
    _.delay =>
      @$name.
        text(@activeBoard.get 'name').
        attr 'data-state', 'fade-in'
    , 500

    # Wait for page to come into focus
    _.delay =>
      @checkForRankChanges()
      @updateBoard @boards.previous()
    , @transitionDuration

  logBoardUpdate: (board, model, difference) ->
    if (difference = model.get('difference'))
      @log "Score change: #{board.id} - #{model.entity.id} #{difference}"

  checkForRankChanges: ->
    if @activeBoard.get 'stale'
      @diffBoards()
      @activeBoard.set 'stale', false
      @log "#{@activeBoard.id} was updated"

  getOffsets: ($board) ->
    _.reduce $board.find('.board-value'), (memo, value) ->
      $value = $(value)
      memo[$value.data 'id'] = $value.offset().top
      memo
    , {}

  diffBoards: ->
    @renderActiveTarget()

    $board    = @$activeBoard()
    $target   = @$activeTarget()

    currentOffsets  = @getOffsets $board
    newOffsets      = @getOffsets $target

    currentKeys   = _.keys currentOffsets
    newKeys       = _.keys newOffsets

    moving      = _.intersection currentKeys, newKeys
    appending   = _.without.apply _, [newKeys].concat(currentKeys)
    removing    = _.difference currentKeys, newKeys

    # Move
    _.each moving, (k) ->
      offset = (currentOffsets[k] - newOffsets[k])
      # Move an existing value
      $board.find(".board-value[data-id=#{k}]").css
        transform: "translateY(#{-(offset)}px)"

    # Append
    _.each appending, (k) ->
      $value = $target.find(".board-value[data-id=#{k}]")
      currentYPosition = $value.appendTo($board).offset().top
      offset = currentYPosition - newOffsets[k]
      $value.css transform: "translateY(#{-(offset)}px)"

    # Remove (doesn't actually remove
    # so that we dont have any issues with the positioning)
    _.each removing, (k) ->
      $board.find(".board-value[data-id=#{k}]").
        attr 'data-state', 'fade-out'

    # Render into place so we have a clean slate
    _.delay =>
      @renderBoard @activeBoard
    , 500

  fadeInAndOutScores: ->
    $scores = @$activeBoard().find '.bv-score'
    $scores.attr 'data-state', 'fade-in'
    _.delay ->
      $scores.attr 'data-state', 'fade-out'
    , 3000

  renderBoard: (board) ->
    @$boards.
      filter("[data-id=#{board.id}]").
      html boardTemplate(trending: board.trending.models)
    _.defer =>
      @fadeInAndOutScores()

  renderActiveTarget: ->
    @$activeTarget().html boardTemplate(trending: @activeBoard.trending.models)

  $activeBoard: ->
    @$boards.filter "[data-id=#{@activeBoard.id}]"

  $activeTarget: ->
    @$targets.filter "[data-id=#{@activeBoard.id}]"

  cacheSelectors: ->
    @$rail      = @$('.boards-rail')
    @$name      = @$('#board-name')
    @$boards    = @$('.board-data')
    @$targets   = @$('.board-target')

  bootstrap: ->
    @activeBoard = @boards.first()
    # Run an update
    @boards.update().then =>
      # Initial render
      @boards.each (board) =>
        @renderBoard board
      @play()
      @loadingDone()
      @log 'Starting playback of leaderboard'

  postRender: ->
    @cacheSelectors()
    @bootstrap()

  render: ->
    @$el.html @template
      activeBoard: @activeBoard
      boards: @boards
    _.defer =>
      @postRender()
    this

  remove: ->
    @stop()
    super

  #
  # DEBUG
  #

  reRenderActiveBoard: ->
    @renderBoard @activeBoard

  rotate: ->
    (@$screen ?= @$('#screen')).toggleClass 'is-rotated'

  next: (e) ->
    e.preventDefault()
    @STEP()
