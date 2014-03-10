config  = require '../config/config'
Board   = require './board'

class TrendingArtists extends Board
  initialize: ->
    super
    @set id: 'trending-artists', name: 'Trending Artists'
    @trending.url     = "#{config.API_ROOT}/fair/#{config.FAIR_ID}/trending/artists?size=10"
    @trending.entity  = 'artist'

class TrendingExhibitors extends Board
  initialize: ->
    super
    @set id: 'trending-exhibitors', name: 'Trending Exhibitors'
    @trending.url     = "#{config.API_ROOT}/fair/#{config.FAIR_ID}/trending/partners?size=10"
    @trending.entity  = 'partner'


class FollowedExhibitors extends Board
  initialize: ->
    super
    @set id: 'followed-exhibitors', name: 'Most Followed Exhibitors'
    @trending.url     = "#{config.API_ROOT}/fair/#{config.FAIR_ID}/partners/follows?size=10"
    @trending.entity  = 'partner'

module.exports =
  TrendingArtists: TrendingArtists
  TrendingExhibitors: TrendingExhibitors
  FollowedExhibitors: FollowedExhibitors
