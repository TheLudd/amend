Container = require '../../lib/container'
ModuleNotFound = require '../../lib/ModuleNotFound'

describe 'container', ->

  When -> @subject = new Container @conf, @parent

  describe '#factory', ->
    When ->
      try
        @subject.factory 'foo', @factory
      catch e
        @e = e

    describe 'marks the factory registered', ->
      Given -> @factory = ->
      Then -> @subject.isRegistered('foo') == true

    describe 'null input', ->
      Then -> @e?
      And -> @e.message == 'A factory must be a function'

    describe 'valid input', ->
      getFoo = ->
        try
          @result = @subject.get 'foo'
        catch e
          @error = e

      describe 'no dependency function', ->
        Given -> @factory = -> 'fooValue'
        When getFoo
        Then -> @result == 'fooValue'

      describe 'non existing dependencies', ->
        Given -> @factory = (bar) ->
        When getFoo
        Then -> @error instanceof ModuleNotFound
        And -> @error.module == 'bar'
        And -> @error.caller == 'foo'

      describe 'one dependency', ->
        Given -> @factory = (bar) -> bar * 2
        When -> @subject.factory 'bar', -> 2
        When getFoo
        Then -> @result == 4

      describe 'with specified dependencies', ->
        Given -> @conf = modules: foo: [ 'bar' ]
        Given -> @factory = (a) -> a * 2
        When -> @subject.value 'bar', 2
        When -> @result = @subject.get 'foo'
        Then -> @result = 4

      describe 'dependency hierarchy', ->
        Given -> @factory = (c) -> 'Now I know my ' + c
        When ->
          @subject.factory 'a', -> 'a'
          @subject.factory 'b', (a) -> a + 'b'
          @subject.factory 'c', (b) -> b + 'c'
        Then -> @result = 'Now I know my abc'

      describe 'factory with value dependency', ->
        Given -> @factory = (a) -> a + 'foo'
        When ->
          @subject.value 'a', 'a'
        When -> @result = @subject.get 'foo'
        Then -> @result == 'afoo'

      describe 'with parent dependency', ->
        Given ->
          @parent = new Container()
          @parent.value 'parentDep', 'bar'

        describe 'then dependency is registered', ->
          Then -> @subject.isRegistered 'parentDep'

        describe 'can fetch from parent', ->
          When -> @result = @subject.get 'parentDep'
          Then -> @result == 'bar'

        describe 'can have chained dependencies towards parent', ->
          When ->
            @subject.factory 'test', (parentDep) -> return parentDep
            @result = @subject.get 'test'
          Then -> @result == 'bar'

  describe '#value', ->
    Given -> @value = 'hey'
    When -> @subject.value 'foo', @value
    When -> @result = @subject.get 'foo'
    Then -> @result == 'hey'

    describe 'marks the value as registerd', ->
      Then -> @subject.isRegistered('foo') == true

  describe '#get', ->
    When ->
      try
        @result = @subject.get @module
      catch e
        @e = e

    describe 'nonExisting', ->
      Given -> @module = 'nonExisting'
      Then -> @e.module == 'nonExisting'

  describe '#class', ->
    When ->
      try
        @subject.class 'foo', @class
      catch e
        @e = e

    describe 'non valid constuctor', ->
      Then -> @e.message == 'A constructor must be a function'

    describe 'valid constructor', ->
      Given -> @class =
        class ExampleClass
          constructor: -> @bar = 'baz'
      When -> @result = @subject.get 'foo'
      Then -> !@e?
      And -> @result.bar == 'baz'
      And -> @subject.isRegistered('foo') == true

    describe 'constructor with dependencies', ->
      Given -> @class =
        class DependingClass
          constructor: (otherModule) -> @foo = otherModule
      When -> @subject.value 'otherModule', 'bar'
      When -> @result = @subject.get 'foo'
      Then -> @result.foo == 'bar'

  describe '#isRegistered', ->
    Then -> !@subject.isRegistered 'nonExisting'

  describe '#getArguments', ->
    When -> @subject.factory 'foo', (a, b, c) ->
    When -> @result = @subject.getArguments('foo')
    Then -> @result.length == 3
    And -> @result[0] = 'a'
    And -> @result[1] = 'b'
    And -> @result[2] = 'c'

  describe '#loadAll', ->
    Given -> @foo2Count = 0
    When -> @subject.factory 'foo', (foo2) ->
    When -> @subject.factory 'foo2', => @foo2Count++
    When -> @subject.class 'bar', class Bar
    When -> @subject.class 'bar2', class Bar2
    When -> @subject.loadAll()
    When -> @result = Object.keys(@subject._instances)
    Then -> @result.length == 4
    And -> @foo2Count == 1
