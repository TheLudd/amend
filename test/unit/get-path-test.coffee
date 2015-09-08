getPath = require '../../lib/get-path'

describe 'getPath', ->

  When ->
    @subject = getPath
    @result = @subject(@modConf)

  describe 'shorthand notation', ->
    Given -> @modConf = 'hey'
    Then -> @result == 'hey'

  describe 'full notation', ->
    Given -> @modConf = require: 'thePath'
    Then -> @result == 'thePath'
