getConfPaths = require '../../lib/get-conf-paths'

describe 'getConfPaths', ->

  findPathStub = (base, fileName, callers) ->
    [ base ].concat(callers).concat(fileName).join '/'

  findMouleStub = (base, fileName, callers) ->
    if callers[0] == 'parent1' && fileName == './parent-config.json'
      modules:
        bee: 'boo'

  When ->
    conf =
      parents: [
        nodeModule: 'parent1'
        configFile: './parent-config.json'
      ]
      modules:
        foo: 'bar'
        baz:
          require: './qux'
    @subject = getConfPaths(findPathStub, findMouleStub)
    @result = @subject('root', conf)
  Then -> @result.should.deep.equal [
    { isLocal: true, isConfig: true, path: 'root/parent1/parent-config.json' }
    { isLocal: false, key: 'bee', path: 'root/parent1/boo' }
    { isLocal: false, key: 'foo', path: 'root/bar' }
    { isLocal: true, key: 'baz', path: 'root/qux' }
  ]
