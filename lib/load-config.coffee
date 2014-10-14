Container = require './container'

isRelative = (path) -> path.indexOf('.') == 0

getFullPath = (path, basePath) ->
  if window? || !isRelative(path)
    return path
  else
    return [ basePath, path ].join '/'

evaluateType = (moduleConfig, module) ->
  return moduleConfig.type if moduleConfig.type?
  path = moduleConfig.require || moduleConfig
  if typeof module == 'function' && isRelative path
    return 'factory'
  else
    return 'value'

getPath = (moduleConfig) ->
  if typeof moduleConfig == 'string'
    return moduleConfig
  else
    return moduleConfig.require

module.exports = (config, basePath, opts = {}) ->
  throw new TypeError('No configuration was provided for loadConfig') unless config?
  di = new Container opts
  modules = config.modules || {}

  Object.keys(modules).forEach (key) ->
    moduleConfig = modules[key]
    path = getPath moduleConfig
    fullPath = getFullPath path, basePath
    module = require fullPath
    type = evaluateType moduleConfig, module
    if type == 'factory'
      di.factory key, module
    else
      di.value key, module

  return di
