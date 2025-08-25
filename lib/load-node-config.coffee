debug = require('debug')('amend:node-config')
Container = require './container'
findModule = require('./find-module').instance
findPath = require('./find-module').path
populateDi = require('./populate-di')(findModule)
addParent = require('./add-parent')(findModule, populateDi)
getConfPaths = require('./get-conf-paths')(findPath, findModule)
cc = require('./clear-cache')

getPath = (o) -> o.path

module.exports = (opts) ->
  { config, baseDir, annotations, clearCache } = opts
  debug 'loading Node.js config from base: %s', baseDir
  debug 'config: %o', config
  debug 'options: clearCache=%s, annotations=%o', !!clearCache, annotations

  if clearCache
    debug 'clearing cache for configuration paths'
    confPaths = getConfPaths(baseDir, config).map(getPath)
    debug 'clearing cache for paths: %j', confPaths
    cc(confPaths)

  debug 'creating container with annotations: %o', annotations
  di = new Container(annotations)
  
  parentCount = config.parents?.length || 0
  debug 'processing %d parent configurations', parentCount
  config.parents?.forEach (p) ->
    debug 'adding parent: %o', p
    parentOpts = Object.assign {}, opts,
      base: baseDir
      parentSpec: p
    addParent di, parentOpts

  debug 'populating DI container with main modules'
  populateOpts = Object.assign {}, opts,
    base: baseDir
    modules: config.modules
  populateDi di, populateOpts
  
  debug 'Node.js config loading completed'
  di
