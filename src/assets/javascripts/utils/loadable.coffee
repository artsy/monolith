_ = require 'underscore'

module.exports =
  loadingDone: ->
    _.delay =>
      ($loading = @$('#loading')).attr 'data-state', 'fade-out'
      _.delay ->
        $loading.remove()
      , 1500
    , 1500
