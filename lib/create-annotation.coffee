{ join } = require('path')
{ both, map, mergeAll, pickBy, concat, reduce } = require('ramda')
analyzeFileDependencies = require './analyse-file-dependencies'

isNotValue = (v) -> v.type != 'value'
getPath = (v) -> if typeof v == 'string' then v else v.require
isLocal = (v) -> getPath(v).startsWith('.')

module.exports = (cwd, config, moduleName = '') ->
  { modules = {} } = config
  base = join(cwd, moduleName)
  cleanModules = pickBy both(isNotValue, isLocal), modules
  resolvedModules = map(((s) -> require.resolve(s, { paths: [ base ] })), cleanModules)
  return Promise.all(map(analyzeFileDependencies, Object.entries(resolvedModules))).then(mergeAll)
