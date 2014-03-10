Collection  = require '../core/collection'
Board       = require '../models/board'

module.exports = class Boards extends Collection
  model: Board

  next: ->
    active = @active()
    active.set('active', false)
    (@at(@indexOf(active) + 1) or @first()).
      set 'active', true

  active: ->
    @find((board) ->
      board.get 'active'
    ) or @first()

  previous: ->
    @at(@indexOf(@active()) - 1) or @last()

  # Run updates on all the boards
  update: ->
    dfd = $.Deferred()
    @trigger 'update:starting'
    $.when.apply(null, @map (board) =>
      board.update()
    ).then =>
      @trigger 'update:complete'
      dfd.resolve()
    dfd.promise()
