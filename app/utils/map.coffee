Maps = require './maps'

module.exports =
  hasMap: (key) ->
    _.contains @availableMaps(), key

  availableMaps: ->
    _.keys Maps

  toMap: (x, y, key) ->
    Maps[key].call this, x, y

  # Get out map based on original input dimensions
  # This is based on the map used to construct 'the-armory-show-2014'
  # and may have to be changed
  original: (x, y) ->
    offset = -5
    [x, y] = [(x * 1022) + offset, (y * 1102) + offset]

  rotate: (cx, cy, x, y, angle) ->
    radians = (Math.PI / 180) * angle
    cos = Math.cos radians
    sin = Math.sin radians
    nx = (cos * (x - cx)) - (sin * (y - cy)) + cx
    ny = (sin * (x - cx)) + (cos * (y - cy)) + cy
    [nx, ny]

  translate: (x, y, tx, ty) ->
    [x + tx, y + ty]

  scale: (x, y, xf, yf) ->
    yf = xf unless yf
    [x * xf, y * yf]
