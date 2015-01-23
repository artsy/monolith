config  = require '../config/config'
Model   = require '../core/model'

module.exports = class Feed extends Model
  url: ->
    "#{config.API_ROOT}/fair/#{config.FAIR_ID}/feed"
