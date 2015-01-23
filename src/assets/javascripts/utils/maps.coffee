# Object containing the transformations specific to the
# individual fair maps.

module.exports =
  'the-armory-show-2014': (x, y) ->
    [x, y]  = @original x, y
    [x, y]  = @rotate 0, 0, x, y, -74
    [x, y]  = @scale x, y, 0.87, 0.86
    [x, y]  = @translate x, y, -40, 730
    [x, y]
