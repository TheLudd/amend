Container = require './container'
module.exports = (config) ->
  throw new TypeError() unless config?
  di = new Container()

  Object.keys(config).forEach (key) ->
    path = config[key]
    fullPath = [ process.cwd(), path ].join '/'
    di.factory key, require fullPath

  return di
