Container = require '../../lib/container'
require('chai').should()

describe 'annotate', ->

  Given -> @subject = require '../../lib/annotate'
  When -> @result = @subject @container

  expectEmpty = -> @result.should.deep.equal {}
  newContainer = -> @container = new Container()
  value = (name, value) -> -> @container.value name, value
  factory = (name, func) -> -> @container.factory name, func
  clazz = (name, clazz) -> -> @container.class name, clazz
  resultIs = (obj) -> -> @result.should.deep.equal obj

  describe 'null input', ->
    Then expectEmpty

  describe 'with container', ->
    Given newContainer

    describe 'that is empty', ->
      Then expectEmpty

    describe 'value only container', ->
      Given value 'foo', 'bar'
      Then expectEmpty

    describe 'one factory, no dependencies', ->
      Given factory 'foo', ->
      Then resultIs foo: []

    describe 'one factory, one dependency', ->
      Given factory 'foo', (bar) ->
      Then resultIs foo: [ 'bar' ]

    describe 'one constructor, no dependencies', ->
      Given clazz 'foo', class Test
      Then resultIs 'foo': []

    describe 'one constructor, one dependency', ->
      Given clazz 'foo', class Test
        constructor: (bar) ->
      Then resultIs foo: [ 'bar' ]

    describe 'several modules', ->
      Given value 'foo', 1
      Given factory 'bar', (a, b, c) ->
      Given factory 'baz', (foo, bar) ->
      Given clazz 'qux', class Quz
        constructor: (x, y, z) ->
      Given clazz 'abc', class Abc
        constructor: (qux, foo) ->
      Then resultIs
        bar: [ 'a', 'b', 'c' ]
        baz: [ 'foo', 'bar' ]
        qux: [ 'x', 'y', 'z' ]
        abc: [ 'qux', 'foo' ]

  describe 'with parent', ->
    Given ->
      parent = new Container()
      parent.factory 'foo', (bar) ->
      @container = new Container(null, [parent])
      @container.factory 'baz', (foo) ->
    Then resultIs
      foo: [ 'bar' ]
      baz: [ 'foo' ]
