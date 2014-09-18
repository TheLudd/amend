loadConfig = require '../../lib/load-config'
describe 'loadConfig', ->

  When ->
    try
      @di = loadConfig @config
    catch e
      @e = e
  Then -> @e?

  describe 'one factory', ->
    Given -> @config =
      foo: './test/e2e/simple-factory'
    When -> @foo = @di.get('foo')
    Then -> @foo == 'fooValue'
