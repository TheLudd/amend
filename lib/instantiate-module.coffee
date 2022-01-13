module.exports = (path) ->
  value = require(path)
  if value.__esModule == true
  then value.default
  else value


