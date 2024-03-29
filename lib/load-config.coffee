normalize = require('path').normalize
Container = require './container'
instantiateModule = require './instantiate-module'

isRelative = (path) -> path.indexOf('.') == 0

joinPaths = (arr) -> arr.join '/'

getFullPath = (path, basePath) ->
  if window?
    if isRelative(path) && basePath != ''
      normalize(joinPaths([ basePath, path]))
    else
      path
  else if isRelative path
    joinPaths [ basePath, path ]
  else
    joinPaths [ basePath, 'node_modules', path ]

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

clearCache = (modules, basePath) ->
  Object.keys(modules).forEach (key) ->
    moduleConfig = modules[key]
    path = getPath moduleConfig
    fullPath = getFullPath path, basePath
    delete require.cache[require.resolve(fullPath)]

populateContainer = (di, modules, basePath) ->

  Object.keys(modules).forEach (key) ->
    moduleConfig = modules[key]
    path = getPath moduleConfig
    fullPath = getFullPath path, basePath
    try
      module = instantiateModule fullPath
    catch e
      module = instantiateModule path
    type = evaluateType moduleConfig, module
    if type == 'spread'
      di.spread module
    else
      di[type] key, module

module.exports = (options) ->
  { config, basePath, opts, parents } = options
  throw new TypeError('No configuration was provided for loadConfig') unless config?
  clearCache(modules, basePath) if options?.clearCache == true
  di = new Container opts, parents
  modules = config.modules || {}
  configParents = config.parents || []
  configParents.forEach (p) ->
    parentModules = instantiateModule joinPaths [ p.nodeModule, p.configFile ]
    populateContainer(di, parentModules.modules, p.nodeModule)
  populateContainer(di, modules, basePath)

  return di
