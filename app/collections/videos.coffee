config       = require '../config/config'
Video        = require '../models/video'
Collection   = require '../core/collection'

module.exports = class Videos extends Collection
  model: Video

  bindEvents: ->
    @each (video) -> video.bindEvents()

  resetVideos: ->
    @each (video) ->
      video.restart()
      video.set 'played', false

  getNext: ->
    video = @findWhere played: false

    unless video
      @resetVideos()
      video = @models[0]

    video.set 'played', true

    return video

