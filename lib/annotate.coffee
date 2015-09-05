annotateContainer = (container) ->
  modules = container._registrations
  noValues = (i) -> modules[i].type != 'value'
  return Object.keys(modules).filter(noValues).reduce (sum, name) ->
    sum[name] = container.getArguments name
    return sum
  , {}

module.exports = (container) ->
  return {} unless container?

  annotations = container._parents.map(annotateContainer)
  annotations.push(annotateContainer(container))
  return annotations.reduce (acc, item) ->
    Object.keys(item).forEach (key) -> acc[key] = item[key]
    return acc
  , {}
