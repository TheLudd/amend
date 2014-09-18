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
      foo: require: './test/e2e/simple-factory'
    When -> @foo = @di.get('foo')
    Then -> @foo == 'fooValue'

  describe 'depending factory', ->
    Given -> @config =
      bar: require: './test/e2e/depending-factory'
      foo: require: './test/e2e/simple-factory'
    When -> @result = @di.get 'bar'
    Then -> @result == 'foobar'

  describe 'one value', ->
    Given -> @config =
      val: require: './test/e2e/value'
    When -> @result = @di.get 'val'
    Then -> @result == 'the value'

  describe 'factory and value', ->
    Given -> @config =
      foo: require: './test/e2e/value'
      bar: require: './test/e2e/depending-factory'
    When -> @result = @di.get 'bar'
    Then -> @result == 'thebar'

  describe 'function specified as value', ->
    Given -> @config =
      foo:
        require: './test/e2e/simple-factory'
        type: 'value'
    When ->
      module = @di.get 'foo'
      @result = module()
    Then -> @result == 'fooValue'

  describe 'shorthand declaration', ->
    Given -> @config =
      foo: './test/e2e/simple-factory'
    When -> @result = @di.get 'foo'
    Then -> @result == 'fooValue'


