module.exports =
  toMap: (x, y) ->
    [x, y]  = @original x, y
    [x, y]  = @rotate 0, 0, x, y, -74
    [x, y]  = @scale x, y, 0.87, 0.86
    [x, y]  = @translate x, y, -40, 730
    [x, y]

  # Get out map based on original input dimensions
  original: (x, y) ->
    offset = -5
    [x, y] = [(x * 1022) + offset, (y * 1102) + offset]

  rotate: (cx, cy, x, y, angle) ->
    radians = (Math.PI / 180) * angle
    cos   = Math.cos radians
    sin   = Math.sin radians
    nx  = (cos * (x - cx)) - (sin * (y - cy)) + cx
    ny  = (sin * (x - cx)) + (cos * (y - cy)) + cy
    [nx, ny]

  translate: (x, y, tx, ty) ->
    [x + tx, y + ty]

  scale: (x, y, xf, yf) ->
    yf = xf unless yf
    [x * xf, y * yf]
