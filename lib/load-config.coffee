normalize = require('path').normalize
debug = require('debug')('amend:config')
Container = require './container'
instantiateModule = require './instantiate-module'

isRelative = (path) -> path.indexOf('.') == 0

joinPaths = (arr) -> arr.join '/'

getFullPath = (path, basePath) ->
  debug 'resolving path: %s with base: %s', path, basePath
  result = if window?
    if isRelative(path) && basePath != ''
      normalize(joinPaths([ basePath, path]))
    else
      path
  else if isRelative path
    joinPaths [ basePath, path ]
  else
    joinPaths [ basePath, 'node_modules', path ]
  debug 'resolved path to: %s', result
  result

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
  moduleKeys = Object.keys(modules)
  debug 'clearing cache for %d modules: %j', moduleKeys.length, moduleKeys
  moduleKeys.forEach (key) ->
    moduleConfig = modules[key]
    path = getPath moduleConfig
    fullPath = getFullPath path, basePath
    debug 'clearing cache for: %s -> %s', key, fullPath
    delete require.cache[require.resolve(fullPath)]

populateContainer = (di, modules, basePath) ->
  moduleKeys = Object.keys(modules)
  debug 'populating container with %d modules from base: %s', moduleKeys.length, basePath
  debug 'modules to process: %j', moduleKeys

  moduleKeys.forEach (key) ->
    moduleConfig = modules[key]
    path = getPath moduleConfig
    fullPath = getFullPath path, basePath
    debug 'processing module "%s": path=%s, config=%o', key, path, moduleConfig
    try
      debug 'attempting to instantiate from full path: %s', fullPath
      module = instantiateModule fullPath
    catch e
      debug 'full path failed (%s), trying original path: %s', e.message, path
      module = instantiateModule path
    type = evaluateType moduleConfig, module
    debug 'evaluated module "%s" as type: %s', key, type
    if type == 'spread'
      debug 'spreading module: %s', key
      di.spread module
    else
      debug 'registering "%s" as %s', key, type
      di[type] key, module

module.exports = (options) ->
  { config, basePath, opts, parents } = options
  debug 'loading config with options: %o', options
  
  throw new TypeError('No configuration was provided for loadConfig') unless config?
  modules = config.modules || {}
  if options?.clearCache == true
    debug 'clearing module cache as requested'
    clearCache(modules, basePath)
  debug 'creating container with opts: %o, parents count: %d', opts, parents?.length || 0
  di = new Container opts, parents
  configParents = config.parents || []
  debug 'processing %d parent configurations', configParents.length
  configParents.forEach (p) ->
    debug 'loading parent: %o', p
    parentModules = instantiateModule joinPaths [ p.nodeModule, p.configFile ]
    populateContainer(di, parentModules.modules, p.nodeModule)
  debug 'populating main modules'
  populateContainer(di, modules, basePath)

  debug 'config loading completed'
  return di
