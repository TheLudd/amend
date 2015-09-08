evaluateType = require './evaluate-type'
getPath = require './get-path'

module.exports = (
  findModule
) ->

  (di, base, modules, callers) ->
    Object.keys(modules).forEach (key) ->
      mod = modules[key]
      path = getPath mod
      instance = findModule(base, path, callers)
      type = evaluateType(mod, instance)
      di[type] key, instance
    return di
