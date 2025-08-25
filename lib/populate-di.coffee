debug = require('debug')('amend:populate')
evaluateType = require './evaluate-type'
getPath = require './get-path'

module.exports = (
  findModule
) ->

  (di, opts) ->
    { base, modules, callers = [] } = opts
    debug 'populating DI container with %d modules from base: %s', Object.keys(modules).length, base
    debug 'modules to populate: %j', Object.keys(modules)
    Object.keys(modules).forEach (key) ->
      mod = modules[key]
      fileName = getPath mod
      debug 'processing module "%s" from file: %s', key, fileName
      debug 'module config: %o', mod
      instance = findModule(Object.assign({}, { base, fileName, callers }, opts))
      type = evaluateType(mod, instance)
      debug 'resolved module "%s" as type: %s', key, type
      di[type] key, instance
      debug 'registered "%s" in DI container', key
    debug 'finished populating DI container'
    return di
