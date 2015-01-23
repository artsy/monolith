Model = require '../core/model'

module.exports = class Artwork extends Model
  image: (version = 'large') ->
    image = @get('images')[0]
    image.image_url.replace ':version', version
