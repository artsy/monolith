config  = require '../config/config'
Model   = require '../core/model'

module.exports = class Show extends Model
  image: (version = 'large') ->
    # Check for New Museum
    if @get('partner').default_profile_id is 'newmuseum'
      '../images/new-museum.jpg'
    else
      @get('image_url')?.replace(':version', version) or
      # Fallback image
      "#{config.API_ROOT}/profile/#{@get('partner').default_profile_id}/image?xapp_token=#{env.XAPP_TOKEN}"

  displayLocation: ->
    location = @get('fair_location')?.display
    if location
      _.each [
        'Contemporary, ',
        'Modern, ',
         '- Curated by Philip Tinari, '
      ], (string) ->
        location = location.replace string, ''
      location

  location: ->
    map_points = @get('fair_location').map_points
    if map_points.length
      { x, y } = map_points[0]
      [x, y]
    else
      []
