{ dirname } = require('path')
{ append, map, mergeAll } = require 'ramda'
createAnnotation = require './create-annotation'

annotateConfig = (cwd, config, moduleName = '') ->
  { parents = [] } = config
  parentAnnotations = map (p) ->
    { nodeModule, configFile } = p
    parentPath = require.resolve("#{nodeModule}/#{configFile}", paths: [ cwd ])
    moduleDir = dirname require.resolve("#{nodeModule}/package.json", paths: [ cwd ])
    parentConfig = require(parentPath)
    annotateConfig moduleDir, parentConfig
  , parents

  configAnnotations = createAnnotation cwd, config
  return Promise.all(append(configAnnotations, parentAnnotations)).then(mergeAll)

module.exports = annotateConfig
