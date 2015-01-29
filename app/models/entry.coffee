config  = require '../config/config'
Model   = require '../core/model'

module.exports = class Entry extends Model

  parse: (data)-> data.payload
