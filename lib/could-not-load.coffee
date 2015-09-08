makePath = require './make-path'

createMessage = (base, module, callers) ->
  callers.reduce (acc, item, i) ->
    acc.concat makePath(base, module, callers[0..i])
  , []

class CouldNotLoad extends Error
  constructor: (@base, @module, @callers) ->
    places = createMessage(@base, @module, @callers)
    @message = "Could not load module #{@module}. Tried in these places:\n#{places.join(',\n')}"

module.exports = CouldNotLoad
