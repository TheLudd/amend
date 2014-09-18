Container = require './container'

evaluateType = (moduleConfig, module) ->
  return moduleConfig.type if moduleConfig.type?
  if typeof module == 'function'
    return 'factory'
  else
    return 'value'

getPath = (moduleConfig) ->
  if typeof moduleConfig == 'string'
    return moduleConfig
  else
    return moduleConfig.require

module.exports = (config) ->
  throw new TypeError() unless config?
  di = new Container()

  Object.keys(config).forEach (key) ->
    moduleConfig = config[key]
    path = getPath moduleConfig
    fullPath = [ process.cwd(), path ].join '/'
    module = require fullPath
    type = evaluateType moduleConfig, module
    if type == 'factory'
      di.factory key, module
    else
      di.value key, module

  return di
