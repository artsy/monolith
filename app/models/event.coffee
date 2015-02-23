config  = require '../config/config'
Model   = require '../core/model'
renderer = new marked.Renderer

module.exports = class Event extends Model

  # this parses the capital letters in the description and makes them
  # bold and on their own line
  parse: (data)->
    description = data.description?.replace /\b([A-Z :]{3,})\b/g, (match)->
      match = match.replace ":", ""
      "**#{match}**\n"

    data.description = description
    data

  formatDateTime: (attr, format)->
    moment(@get(attr)).format(format)

  mdToHtml: (attr, options = {}) ->
    marked.setOptions _.defaults options,
      renderer: renderer
      gfm: true
      tables: true
      breaks: true
      pedantic: false
      sanitize: true
      smartypants: false
    marked @get(attr) or ''


