getPath = require './get-path'
{ normalize } = require 'path'

module.exports = (
  findPath
  findMoule
) ->

  isLocal = (path) -> path[0] == '.'

  getModulePaths = (base, conf, childCallers = []) ->
    modules = conf.modules
    parentConfigs = conf.parents || []
    out = []
    parentConfigs.forEach (p) ->
      callers = childCallers.concat p.nodeModule
      parentConf = findMoule base, p.configFile, callers
      parentConfPath = findPath base, p.configFile, callers
      out.push isConfig: true, isLocal: true, path: normalize parentConfPath
      out = out.concat getModulePaths(base, parentConf, callers)
    Object.keys(modules).map (key) ->
      mod = modules[key]
      path = getPath(mod)
      out.push
        key: key
        path: normalize findPath(base, path, childCallers)
        isLocal: isLocal(path)

    return out
