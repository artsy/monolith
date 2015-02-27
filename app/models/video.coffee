config  = require '../config/config'
Model   = require '../core/model'

module.exports = class Video extends Model
  almostDone: 90
  defaults:
    played: false

  bindEvents: ->
    @$el().on 'ended', @ended
    @$el().on 'timeupdate', @progress

  $el: -> $("##{@id}")

  source: -> @$el().get(0)

  restart: -> @source().currentTime = 0

  ended: =>
    @collection.trigger 'video:complete'

  progress: =>
    if @source().duration
      percent = (@source().currentTime / @source().duration) * 100
      @collection.trigger('video:almostDone') if percent > @almostDone



