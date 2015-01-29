config  = require '../config/config'
Model   = require '../core/model'

module.exports = class Entry extends Model

  parse: (data)-> data.payload

  getCaption: ->
    emoji.replace_unified @get('caption').text

