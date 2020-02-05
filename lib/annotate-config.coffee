{ dirname } = require('path')
{ chain, append, mergeAll } = require 'ramda'
createAnnotation = require './create-annotation'

module.exports = (cwd, config, moduleName = '') ->
  { parents = [] } = config
  parentAnnotations = chain (p) ->
    { nodeModule, configFile } = p
    parentPath = require.resolve("#{nodeModule}/#{configFile}", paths: [ cwd ])
    moduleDir = dirname require.resolve("#{nodeModule}/package.json", paths: [ cwd ])
    parentConfig = require(parentPath)
    annotateConfig moduleDir, parentConfig
  , parents

  configAnnotations = createAnnotation cwd, config
  return Promise.all(append(configAnnotations, parentAnnotations)).then(mergeAll)
