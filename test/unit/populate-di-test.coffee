populateDi = require '../../lib/populate-di'
Container = require '../../lib/container'

describe 'populateDi', ->

  Given ->
    @findModuleSpy = ({ base, fileName, callers }) =>
      @baseResult = base
      @callersResult = callers
      if fileName == 'bar'
        'barContent'
      else if fileName == 'boo'
        -> 'boo content'
      else
        -> 'factory content'
  When ->
    @di = new Container
    modules =
      foo: 'bar'
      baz: './qux'
      bee:
        require: 'boo'
        type: 'factory'
    @subject = populateDi(@findModuleSpy)
    opts =
      base: 'root'
      modules: modules
      callers: 'callers'

    @returned = @subject(@di, opts)

  Invariant -> @baseResult == 'root'
  Invariant -> @callersResult == 'callers'
  Invariant -> @returned == @di

  describe 'value ', ->
    When -> @result = @di.get 'foo'
    Then -> @result == 'barContent'

  describe 'factory ', ->
    When -> @result = @di.get 'baz'
    Then -> @result == 'factory content'

  describe 'type specified ', ->
    When -> @result = @di.get 'bee'
    Then -> @result == 'boo content'
