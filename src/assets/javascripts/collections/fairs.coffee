_           = require 'underscore'
config      = require '../config/config'
Collection  = require '../core/collection'

module.exports = class Fairs extends Collection
  url: "#{config.API_ROOT}/fairs"

  comparator: (fair) ->
    -fair.get 'created_at'

  parse: (response) ->
    _.filter response, (fair) ->
      not _.isNull fair.organizer
