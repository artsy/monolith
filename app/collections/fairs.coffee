config      = require '../config/config'
Collection  = require '../core/collection'

module.exports = class Fairs extends Collection
  url: "#{config.API_ROOT}/fairs"
