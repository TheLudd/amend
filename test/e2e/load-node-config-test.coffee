loadNodeConfig = require '../../lib/load-node-config'

describe 'loadNodeConfig', ->

  config =
    parents: [
      { nodeModule: 'fake1', configFile: './fake1-config.json' }
      { nodeModule: 'fake2', configFile: './fake2-config.json' }
    ]
    modules:
      simpleFactory: './test/e2e/simple-factory'

  When ->
    opts =
      config: config
      baseDir: process.cwd()
      annotations: 'someAnnotations'
    @subject = loadNodeConfig(opts)
  Then -> @subject.get('simpleFactory', 'fooValue')
  And -> @subject._modules == 'someAnnotations'
