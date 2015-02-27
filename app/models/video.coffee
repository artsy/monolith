config  = require '../config/config'
Model   = require '../core/model'

module.exports = class Video extends Model
  defaults:
    played: false

  bindEvents: ->
    @$el().on 'ended', @ended

  $el: -> $("##{@id}")

  ended: =>
    @collection.trigger 'video:complete'

