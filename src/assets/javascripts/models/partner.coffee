_       = require 'underscore'
config  = require '../config/config'
Model   = require '../core/model'
Shows   = require '../collections/shows'

module.exports = class Partner extends Model
  image: ->
    @shows?.first()?.image('square') or
    # Fallback image
    "#{config.API_ROOT}/profile/#{@get('default_profile_id')}/image?xapp_token=#{env?.XAPP_TOKEN}"

  fetchShows: (options = {}) ->
    @shows ?= new Shows
    @shows.fetch _.extend options, data: partner: @id
