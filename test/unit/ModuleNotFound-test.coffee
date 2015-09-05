ModuleNotFound = require '../../lib/ModuleNotFound'

describe 'ModuleNotFound', ->

  When -> @subject = new ModuleNotFound('foo', @caller)
  When -> @result = @subject.message

  describe 'without caller', ->
    Then -> @subject.module == 'foo'
    And -> @result == 'Could not find any module with name foo'

  describe 'with caller', ->
    Given -> @caller = 'bar'
    Then -> @subject.caller == 'bar'
    And -> @result == 'Could not find any module with name foo, required from module bar'
