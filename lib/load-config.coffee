Container = require './container'

isRelative = (path) -> path.indexOf('.') == 0

getFullPath = (path, basePath) ->
  if window?
    return path
  else if isRelative path
    return [ basePath, path ].join '/'
  else
    return [ basePath, 'node_modules', path ].join '/'

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

module.exports = (config, basePath, opts = {}, parent) ->
  throw new TypeError('No configuration was provided for loadConfig') unless config?
  di = new Container opts, parent
  modules = config.modules || {}

  Object.keys(modules).forEach (key) ->
    moduleConfig = modules[key]
    path = getPath moduleConfig
    fullPath = getFullPath path, basePath
    try
      module = require fullPath
    catch e
      module = require path
    type = evaluateType moduleConfig, module
    if type == 'factory'
      di.factory key, module
    else
      di.value key, module

  return di
