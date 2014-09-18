Container = require '../../lib/container'

describe 'container', ->

  Given -> @subject = new Container

  describe '#factory', ->
    When ->
      try
        @subject.factory 'foo', @factory
      catch e
        @e = e

    describe 'null input', ->
      Then -> @e?
      And -> @e.message == 'A factory must be a function'

    describe 'valid input', ->
      When -> @result = @subject.get 'foo'

      describe 'no dependency function', ->
        Given -> @factory = -> 'fooValue'
        Then -> @result == 'fooValue'

      describe 'one dependency', ->
        Given -> @subject.factory 'bar', -> 2
        Given -> @factory = (bar) -> bar * 2
        Then -> @result == 4

      describe 'dependency hierarchy', ->
        Given ->
          @subject.factory 'a', -> 'a'
          @subject.factory 'b', (a)-> a + 'b'
          @subject.factory 'c', (b)-> b + 'c'
          @factory = (c) -> 'Now I know my ' + c
        Then -> @result = 'Now I know my abc'

  describe '#value', ->
    Given -> @value = 'hey'
    When -> @subject.value 'foo', @value
    When -> @result = @subject.get 'foo'
    Then -> @result == 'hey'
