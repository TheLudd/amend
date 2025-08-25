debug = require('debug')('amend:instantiate')

module.exports = (path) ->
  debug 'instantiating module from path: %s', path
  value = require(path)
  debug 'raw module value type: %s, __esModule: %s', typeof value, value?.__esModule
  if value.__esModule == true
    debug 'ES module detected, returning default export'
    value.default
  else
    debug 'CommonJS module, returning value as-is'
    value


