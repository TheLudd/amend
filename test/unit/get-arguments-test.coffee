describe 'getArguments', ->

  Given -> @subject = require '../../lib/get-arguments'
  When ->
    try
      @result = @subject @func
    catch e
      @e = e

  describe 'null argument', ->
    Then -> @e.message == 'Argument must be a function'

  describe 'no arguments', ->
    Given -> @func = ->
    Then -> @result.length == 0

  describe 'one argument', ->
    Given -> @func = (a) ->
    Then -> @result.length == 1
    And -> @result[0] == 'a'

  describe 'two arguments', ->
    Given -> @func = (a, b) ->
    Then -> @result.length == 2
    And -> @result[0] == 'a'
    And -> @result[1] == 'b'

  describe 'lots of arguments', ->
    Given -> @func = (a, b, c, d, e, f, g, h) ->
    Then -> @result.length == 8

  describe 'no spaces between arguments', ->
    Given -> @func = (a,b) ->
    Then -> @result.length == 2
    And -> @result[0] == 'a'
    And -> @result[1] == 'b'
