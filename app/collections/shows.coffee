config      = require '../config/config'
Collection  = require '../core/collection'
Show        = require '../models/show'

module.exports = class Shows extends Collection
  model: Show

  url: ->
    "#{config.API_ROOT}/fair/#{config.FAIR_ID}/shows"

  parse: (response) ->
    response.results
