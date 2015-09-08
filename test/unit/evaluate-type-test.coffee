evaluateType = require '../../lib/evaluate-type'

describe 'evaluateType', ->

  When ->
    @subject = evaluateType
    @result = @subject(@conf, @instance)

  describe '- when conf specifies the type', ->
    Given -> @conf = type: 'foo'
    Then -> @result == 'foo'

  describe '- shorthand notation, relative path', ->
    Given -> @conf = './somePath'

    describe 'function instance', ->
      Given -> @instance = () ->
      Then -> @result == 'factory'

    describe 'non function instance', ->
      Given -> @instance = 'foo'
      Then -> @result == 'value'

  describe '- shorthand notation, dependency path', ->
    Given ->
      @conf = 'someDependency'
      @instance = () ->
    Then -> @result == 'value'
