Container = require '../../lib/container'

describe 'container', ->

  Given -> @subject = new Container

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
          @subject.factory 'b', (a) -> a + 'b'
          @subject.factory 'c', (b) -> b + 'c'
          @factory = (c) -> 'Now I know my ' + c
        Then -> @result = 'Now I know my abc'

      describe 'factory with value dependency', ->
        Given ->
          @subject.value 'a', 'a'
          @factory = (a) -> a + 'foo'
        When -> @result = @subject.get 'foo'
        Then -> @result == 'afoo'

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
      Then -> @e.message == 'Could not find any module with name nonExisting'

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
    Given -> @subject.factory 'foo', (a, b, c) ->
    When -> @result = @subject.getArguments('foo')
    Then -> @result.length == 3
    And -> @result[0] = 'a'
    And -> @result[1] = 'b'
    And -> @result[2] = 'c'

  describe '#loadAll', ->
    Given -> @foo2Count = 0
    Given -> @subject.factory 'foo', (foo2) ->
    Given -> @subject.factory 'foo2', => @foo2Count++
    Given -> @subject.class 'bar', class Bar
    Given -> @subject.class 'bar2', class Bar2
    When -> @subject.loadAll()
    When -> @result = Object.keys(@subject.instances)
    Then -> @result.length == 4
    And -> @foo2Count == 1
