config       = require '../config/config'
Event        = require '../models/event'
Collection   = require '../core/collection'

module.exports = class Events extends Collection
  model: Event

  url: -> "#{env.EUROPA_ENDPOINT}/api/events"