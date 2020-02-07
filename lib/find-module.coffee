makePath = require './make-path'
CouldNotLoad = require './could-not-load'

findModule = (base, fileName, callers) ->
  fullPath =  makePath base, fileName, callers
  try
    instance: require fullPath
    path: fullPath
  catch e
    if callers.length > 0
      findModule base, fileName, callers[0..-2]
    else
      throw e

tryFind = (base, fileName, callers) ->
  try
    instance: require fileName
    path: fileName
  catch e
    if e.code == 'MODULE_NOT_FOUND'
      try
        findModule(base, fileName, callers)
      catch e2
        throw new CouldNotLoad base, fileName, callers, e2
    else
      instance: {}
      path: makePath base, fileName, callers

resolveAsNode = (base, fileName, callers) ->
  paths = callers.map (item) -> "#{base}/node_modules/#{item}"
  paths.push(base)
  fullPath = require.resolve(fileName, { paths: paths })
  return fullPath.replace(/\.js$/, '')

exports.instance = (base, fileName, callers) ->
  if typeof window == 'undefined'
    return require(resolveAsNode(base, fileName, callers))
  tryFind(base, fileName, callers).instance

exports.path = (base, fileName, callers) ->
  if typeof window == 'undefined'
    return resolveAsNode(base, fileName, callers)
  tryFind(base, fileName, callers).path
