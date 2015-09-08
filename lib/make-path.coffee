{ normalize } = require 'path'
prependNodeModules = (v) -> [ 'node_modules', v ]
concatRight = (a1, a2) -> a2.concat a1
isLocalFile = (path) -> path[0] == '.'

module.exports = (base, path, callers) ->
  if callers.length == 0 && isLocalFile(path)
    out = path
  else
    end = if isLocalFile path then path else prependNodeModules path
    out = callers.map(prependNodeModules).reduceRight(concatRight, end).join '/'

  normalize [ base, out ].join '/'
