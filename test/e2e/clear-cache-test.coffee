expect = require('chai').expect
clearCacheFile = '../../lib/clear-cache'
clearCache = require clearCacheFile

describe 'clearCache', ->

  When ->
    @clearThis = [
      require.resolve(clearCacheFile)
      __filename
    ]
    clearCache(@clearThis)
  Then -> @clearThis.forEach (f) -> expect(require.cache[f]).to.be.undefined
