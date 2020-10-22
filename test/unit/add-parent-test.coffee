addParent = require '../../lib/add-parent'
Container = require '../../lib/container'

describe 'addParent', ->

  Given ->
    @modulesSearched = []
    @findModuleSpy = ({ base, fileName, callers }) =>
      paths = [ base ].concat(callers).concat fileName
      @modulesSearched.push(paths.join('/'))
      if fileName == 'p-conf'
        parents: [
          { configFile: 'next-p-conf', nodeModule: 'some-other-parent' }
        ]
        modules: 'parentModules'
      else
        modules: 'grandParentModules'

    addIndex = 0
    @populateDISpy = (di, opts) ->
      { base, modules, callers } = opts
      key = [ base ].concat(callers).join '/'
      di.value key, modules + addIndex++

  When ->
    parentSpec =
      configFile: 'p-conf'
      nodeModule: 'some-parent'

    @di = new Container()
    @subject = addParent(@findModuleSpy, @populateDISpy)
    opts =
      base: 'root'
      parentSpec: parentSpec
      childCallers: []

    @subject(@di, opts)

  Then -> @modulesSearched[0] == 'root/some-parent/p-conf'
  And -> @modulesSearched[1] == 'root/some-parent/some-other-parent/next-p-conf'
  And -> @di.get('root/some-parent/some-other-parent') == 'grandParentModules0'
  And -> @di.get('root/some-parent') == 'parentModules1'
