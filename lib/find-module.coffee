{ normalize, join, dirname } = require 'path'
makePath = require './make-path'
CouldNotLoad = require './could-not-load'
instantiateModule = require './instantiate-module'

tryCustomPath = (opts) ->
  { getCustomPath } = opts
  fullPath = getCustomPath(opts)
  instance: instantiateModule fullPath
  path: fullPath

findModule = (opts) ->
  { base, fileName, callers, getCustomPath } = opts
  fullPath =  makePath base, fileName, callers
  try
    instance: instantiateModule fullPath
    path: fullPath
  catch e
    if getCustomPath?
      tryCustomPath opts
    else if callers.length > 0
      findModule base, fileName, callers[0..-2]
    else
      throw e

tryFind = (opts) ->
  { base, fileName, callers } = opts
  try
    instance: instantiateModule fileName
    path: fileName
  catch e
    if e.code == 'MODULE_NOT_FOUND'
      try
        findModule(opts)
      catch e2
        throw new CouldNotLoad base, fileName, callers, e
    else
      instance: {}
      path: makePath base, fileName, callers

resolveAsNode = (opts) ->
  { base, fileName, callers } = opts
  paths = callers.map (item) -> "#{base}/node_modules/#{item}"
  paths.push(base)
  try
    fullPath = require.resolve(fileName, { paths: paths })
  catch e
    alternative = normalize(join(callers..., fileName))
    fullPath = require.resolve(alternative, { paths: paths })

  return fullPath.replace(/\.js$/, '')

exports.instance = (opts) ->
  if typeof window == 'undefined'
    return require(resolveAsNode(opts))
  tryFind(opts).instance

exports.path = (opts) ->
  if typeof window == 'undefined'
    return resolveAsNode(opts)
  tryFind(opts).path
