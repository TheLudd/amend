makePath = require '../../lib/make-path'

describe 'makePath', ->

  When ->
    @subject = makePath
    @result = @subject('root', @path, @callers)

  describe '- local file', ->
    Given -> @path = './someFile'

    describe 'with no callers', ->
      Given -> @callers = []
      Then -> @result == "root/someFile"

    describe 'with one caller', ->
      Given -> @callers = [ 'caller1' ]
      Then -> @result == 'root/node_modules/caller1/someFile'

    describe 'with two callers', ->
      Given -> @callers = [ 'caller1', 'caller2' ]
      Then -> @result == 'root/node_modules/caller1/node_modules/caller2/someFile'

  describe '- node dependency', ->
    Given -> @path = 'someDependency'

    describe 'with no callers', ->
      Given -> @callers = []
      Then -> @result == "root/node_modules/#{@path}"

    describe 'with one caller', ->
      Given -> @callers = [ 'caller1' ]
      Then -> @result == 'root/node_modules/caller1/node_modules/someDependency'

    describe 'with two callers', ->
      Given -> @callers = [ 'caller1', 'caller2' ]
      Then -> @result == 'root/node_modules/caller1/node_modules/caller2/node_modules/someDependency'
