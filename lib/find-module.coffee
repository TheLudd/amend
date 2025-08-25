{ normalize, join, dirname } = require 'path'
debug = require('debug')('amend:find-module')
makePath = require './make-path'
CouldNotLoad = require './could-not-load'
instantiateModule = require './instantiate-module'

tryCustomPath = (opts) ->
  { getCustomPath } = opts
  debug 'trying custom path with opts: %o', opts
  fullPath = getCustomPath(opts)
  debug 'custom path resolved to: %s', fullPath
  instance: instantiateModule fullPath
  path: fullPath

findModule = (opts) ->
  { base, fileName, callers, getCustomPath } = opts
  debug 'finding module: fileName=%s, base=%s, callers=%j', fileName, base, callers
  fullPath =  makePath base, fileName, callers
  debug 'generated path: %s', fullPath
  try
    debug 'attempting to instantiate module at: %s', fullPath
    instance: instantiateModule fullPath
    path: fullPath
  catch e
    debug 'failed to load from path %s: %s', fullPath, e.message
    if getCustomPath?
      debug 'trying custom path fallback'
      tryCustomPath opts
    else if callers.length > 0
      debug 'trying with fewer callers: %j', callers[0..-2]
      findModule base, fileName, callers[0..-2]
    else
      debug 'no more fallbacks, throwing error: %s', e.message
      throw e

tryFind = (opts) ->
  { base, fileName, callers } = opts
  debug 'trying to find module in browser environment: %s', fileName
  try
    debug 'attempting direct instantiation of: %s', fileName
    instance: instantiateModule fileName
    path: fileName
  catch e
    debug 'direct instantiation failed: %s', e.message
    if e.code == 'MODULE_NOT_FOUND'
      debug 'MODULE_NOT_FOUND, trying findModule fallback'
      try
        findModule(opts)
      catch e2
        debug 'findModule fallback also failed: %s', e2.message
        throw new CouldNotLoad base, fileName, callers, e
    else
      debug 'non-MODULE_NOT_FOUND error, returning empty instance'
      instance: {}
      path: makePath base, fileName, callers

resolveAsNode = (opts) ->
  { base, fileName, callers } = opts
  debug 'resolving as Node module: fileName=%s, base=%s, callers=%j', fileName, base, callers
  paths = callers.map (item) -> "#{base}/node_modules/#{item}"
  paths.push(base)
  debug 'constructed paths for resolution: %j', paths
  try
    fullPath = require.resolve(fileName, { paths: paths })
    debug 'resolved %s to %s', fileName, fullPath
  catch e
    debug 'initial resolve failed: %s, trying alternative path', e.message
    alternative = normalize(join(callers..., fileName))
    debug 'trying alternative path: %s', alternative
    fullPath = require.resolve(alternative, { paths: paths })
    debug 'alternative resolved to: %s', fullPath

  finalPath = fullPath.replace(/\.js$/, '')
  debug 'final resolved path (js stripped): %s', finalPath
  return finalPath

exports.instance = (opts) ->
  debug 'getting instance for opts: %o', opts
  if typeof window == 'undefined'
    debug 'Node.js environment detected, using require-based resolution'
    resolvedPath = resolveAsNode(opts)
    debug 'requiring resolved path: %s', resolvedPath
    return require(resolvedPath)
  debug 'browser environment detected, using tryFind'
  tryFind(opts).instance

exports.path = (opts) ->
  debug 'getting path for opts: %o', opts
  if typeof window == 'undefined'
    debug 'Node.js environment, returning resolved path'
    return resolveAsNode(opts)
  debug 'browser environment, returning tryFind path'
  tryFind(opts).path
