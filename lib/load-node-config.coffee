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

  cc(getConfPaths(baseDir, config).map(getPath)) if clearCache

  di = new Container(annotations)
  config.parents?.forEach (p) ->
    parentOpts = Object.assign {}, opts,
      base: baseDir
      parentSpec: p
    addParent di, parentOpts

  populateOpts = Object.assign {}, opts,
    base: baseDir
    modules: config.modules
  populateDi di, populateOpts
