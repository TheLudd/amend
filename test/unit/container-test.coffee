Container = require '../../lib/container'
ModuleNotFound = require '../../lib/ModuleNotFound'

describe 'container', ->

  getFoo = ->
    try
      @result = @subject.get 'foo'
    catch e
      @error = e

  When -> @subject = new Container @conf, @parents

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
          @parents = [ @parent ]

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

        describe 'only instantiates parent once', ->
          Given ->
            @parentCount = 0
            @parent.factory 'counter', => @parentCount++
          When ->
            @subject.factory 'test', (counter) =>
            @subject.factory 'test2', (counter) =>
            @subject.get 'test'
            @subject.get 'test2'
          Then -> @parentCount == 1

      describe '- nested parents', ->
        Given ->
          @master = new Container()
          @master.value 'master', 'a'
          @parent = new Container null, [ @master ]
          @parent.factory 'parent', (master) -> master + 'b'
          @parents = [ @parent ]

        describe '- nested parent dependencies', ->
          When -> @subject.factory 'foo', (parent) -> parent + 'c'
          When getFoo
          Then -> @result == 'abc'

        describe '- get from nested parent', ->
          When -> @result = @subject.get 'master'
          Invariant -> @result == 'a'

          describe '(cached)', ->
            When -> @resutl = @subject.get 'master'

      describe '- multiple parents', ->
        Given ->
          @parent1 = new Container()
          @parent1.value 'p1Module', 'a'
          @parent2 = new Container()
          @parent2.value 'p2Module', 'b'
          @parents = [ @parent1, @parent2 ]
        When -> @subject.factory 'foo', (p1Module, p2Module) -> p1Module + p2Module + 'c'
        When getFoo
        Invariant -> @result == 'abc'

        describe '- cached fetch', ->
          When getFoo

  describe '#value', ->
    Given -> @value = 'hey'
    When -> @subject.value 'foo', @value
    When -> @result = @subject.get 'foo'
    Then -> @result == 'hey'

    describe 'marks the value as registerd', ->
      Then -> @subject.isRegistered('foo') == true

  describe '#get', ->
    Given -> @counter = 0
    When -> @subject.factory 'foo', =>
      @counter++
      return undefined

    describe '- nonExisting', ->
      When ->
        try
          @result = @subject.get 'nonExisting'
        catch e
          @e = e
      Then -> @e.module == 'nonExisting'

    describe '- existing', ->
      When getFoo
      Invariant -> @counter == 1

      describe '- only runs the factory once', ->
        When getFoo

      describe '- does not run again in loadAll', ->
        When -> @subject.loadAll()

      describe '- only instantiates dependencies once', ->
        When ->
          @subject.factory 'bar', (foo) ->
          @subject.get 'bar'

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

    describe '- with parent', ->
      Given ->
        @parent = new Container()
        @parent.factory 'loadMe', => @parentLoaded = true
        @parents = [ @parent ]
      Then -> @parentLoaded == true

  describe '#shutdown', ->
    createShutdownable = -> @hasShutdown = __amendShutdown: => @wasShutdown = true
    callShutdown = ->
      @subject.loadAll()
      @subject.shutdown()

    describe '- with no modules', ->
      When callShutdown
      Then ->

    describe '- with shutdownable modules', ->
      Given createShutdownable
      When -> @subject.value 'shutMe', @hasShutdown
      When callShutdown
      Then -> @wasShutdown == true

    describe '- with non shutdownable modules', ->
      Given ->
        @noShutdown = someKey: 'someVal'
      When -> @subject.value 'dontShutMe', @noShutdown
      When callShutdown
      Then ->

    describe '-with factories returning undefined', ->
      When -> @subject.factory 'foo', -> return undefined
      When callShutdown
      Then ->

    describe '- with shutdowns in parent', ->
      Given createShutdownable
      Given ->
        parent = new Container
        parent.value 'shutMe', @hasShutdown
        @parents = [ parent ]
      When callShutdown
      Then -> @wasShutdown == true

  describe '#getRegistrations', ->
    When -> @subject.value 'foo', 'bar'
    getRegistrations = -> @result = @subject.getRegistrations()

    describe '- single container', ->
      When getRegistrations
      Then -> @result.should.deep.equal foo: value: 'bar', type: 'value'

    describe '- with parent container', ->
      Given ->
        parent = new Container
        parent.value 'baz', 'qux'
        @parents = [ parent ]
      When getRegistrations
      Then -> @result.should.deep.equal
        foo: value: 'bar', type: 'value'
        baz: value: 'qux', type: 'value'
