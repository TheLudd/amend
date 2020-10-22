evaluateType = require './evaluate-type'
getPath = require './get-path'

module.exports = (
  findModule
) ->

  (di, opts) ->
    { base, modules, callers = [] } = opts
    Object.keys(modules).forEach (key) ->
      mod = modules[key]
      fileName = getPath mod
      instance = findModule(Object.assign({}, { base, fileName, callers }, opts))
      type = evaluateType(mod, instance)
      di[type] key, instance
    return di
