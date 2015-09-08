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
    try
      findModule(base, fileName, callers)
    catch e2
      throw new CouldNotLoad base, fileName, callers

exports.instance = (base, fileName, callers) ->
  tryFind(base, fileName, callers).instance

exports.path = (base, fileName, callers) ->
  tryFind(base, fileName, callers).path
