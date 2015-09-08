isRelative = (v) -> v[0] == '.'

module.exports = (conf, instance) ->
  if typeof conf == 'string'
    if typeof instance == 'function' && isRelative(conf)
      'factory'
    else
      'value'
  else
    conf.type
