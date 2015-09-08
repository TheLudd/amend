module.exports = (modConf) ->
  if typeof modConf == 'string'
    modConf
  else
    modConf.require
