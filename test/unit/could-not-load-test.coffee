CouldNotLoad = require '../../lib/could-not-load'

describe 'couldNotLoad', ->

  When ->
    callers = [ 'foo', 'bar' ]
    module = 'hey'
    base = 'root'
    @subject = new CouldNotLoad(base, module, callers)
    @result = @subject.message
  Then ->
    @result == '''
      Could not load module hey. Tried in these places:
      root/node_modules/foo/node_modules/hey,
      root/node_modules/foo/node_modules/bar/node_modules/hey
    '''
