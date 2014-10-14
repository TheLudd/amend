loadConfig = require '../../lib/load-config'
describe 'loadConfig', ->

  Given ->
    @opts =
      basePath: process.cwd()
  When ->
    try
      @di = loadConfig @config, @opts
    catch e
      @e = e
  Then -> @e?

  describe 'no modules', ->
    Given -> @config = {}
    Then -> !@e?

  describe 'one factory', ->
    Given -> @config = modules:
      foo: require: './test/e2e/simple-factory'
    When -> @foo = @di.get('foo')
    Then -> @foo == 'fooValue'

  describe 'depending factory', ->
    Given -> @config = modules:
      bar: require: './test/e2e/depending-factory'
      foo: require: './test/e2e/simple-factory'
    When -> @result = @di.get 'bar'
    Then -> @result == 'foobar'

  describe 'one value', ->
    Given -> @config = modules:
      val: require: './test/e2e/value'
    When -> @result = @di.get 'val'
    Then -> @result == 'the value'

  describe 'factory and value', ->
    Given -> @config = modules:
      foo: require: './test/e2e/value'
      bar: require: './test/e2e/depending-factory'
    When -> @result = @di.get 'bar'
    Then -> @result == 'thebar'

  describe 'function specified as value', ->
    Given -> @config = modules:
      foo:
        require: './test/e2e/simple-factory'
        type: 'value'
    When ->
      module = @di.get 'foo'
      @result = module()
    Then -> @result == 'fooValue'

  describe 'shorthand declaration', ->
    Given -> @config = modules:
      foo: './test/e2e/simple-factory'
    When -> @result = @di.get 'foo'
    Then -> @result == 'fooValue'

  describe 'node_module', ->
    Given -> @config = modules:
      m: 'mocha'
    When -> @result = @di.get 'm'
    Then -> @result.test?
