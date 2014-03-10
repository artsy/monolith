Model     = require '../core/model'
Artwork   = require './artwork'
Artist    = require './artist'
Partner   = require './partner'
Shows     = require '../collections/shows'

module.exports = class Action extends Model
  parse: (response) ->
    switch response.type
      when 'ArtworkCollect'
        @entity = new Artwork response.entity
        @entity.artist    = new Artist @entity.get('artist')
        @entity.partner   = new Partner @entity.get('partner')
        @entity.unset 'artist'
        @entity.unset 'partner'
      when 'ArtistFollow'
        @entity = new Artist response.entity
      when 'ProfileFollow'
        @entity = new Partner response.entity
    delete response.entity
    response

  fetchShows: (options = {}) ->
    @shows  = new Shows
    data    = {}
    switch @get 'type'
      when 'ArtworkCollect'
        data.partner = @entity.partner.id
      when 'ArtistFollow'
        data.artist = @entity.id
      when 'ProfileFollow'
        data.partner = @entity.id

    @shows.fetch _.extend options, data: data

  initials: ->
    name = @get('user')?.name
    if name is 'Daniel Doubrovkine'
      return '<span class="is-lowercase">d</span>B'
    else
      if name
        _.reduce name.split(' '), (memo, name) ->
          if not _.isEmpty(name)
            memo += name[0] + '.'
          else
            memo
        , ''
