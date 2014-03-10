Model = require '../core/model'

module.exports = class Artist extends Model
  image: (version = 'large') ->
    @get('image_url').replace ':version', version
