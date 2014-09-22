module.exports = (container) ->
  return {} unless container?

  modules = container._registrations
  noValues = (i) -> modules[i].type != 'value'

  return Object.keys(modules).filter(noValues).reduce (sum, name) ->
    sum[name] = container.getArguments name
    return sum
  , {}
