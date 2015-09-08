req = (p) -> require '../../' + p
findModule = req 'lib/find-module'
CouldNotLoad = req 'lib/could-not-load'

describe 'findModule', ->

  Given ->
    @base = process.cwd()
  When ->
    try
      @resultInstance = findModule.instance(@base, @fileName, @callers)
      @resultPath = findModule.path(@base, @fileName, @callers)
    catch e
      @error = e

  verifyResult = ->
    (@base + '/' + @expectedPath).should.equal @resultPath
    expectedInstance = req @expectedPath
    expectedInstance.should.deep.equal @resultInstance

  afterBlock ->
    if @error?
      @error.should.be.an.instanceof CouldNotLoad
      @error.callers.should.deep.equal @callers
      @error.base.should.deep.equal @base
      @error.module.should.deep.equal @fileName

  describe 'non existing module', ->
    Given ->
      @fileName = './nonExisting'
      @callers = [ 'fake1' ]
    Then -> @error?

  describe 'direct node dependency', ->
    Given ->
      @expectedPath = 'fake1'
      @fileName = 'fake1'
      @callers = []
    Then -> @resultPath == 'fake1'
    Then -> @resultInstance == require('fake1')

  describe '1 module down, local file', ->
    Given ->
      @expectedPath = 'node_modules/fake1/fake1-config.json'
      @fileName = './fake1-config.json'
      @callers = [ 'fake1' ]
    Then verifyResult

  describe '1 module down, dependency', ->
    Given ->
      @expectedPath = 'node_modules/fake2/node_modules/fake3'
      @fileName = 'fake3'
      @callers = [ 'fake2' ]
    Then verifyResult

  describe '1 module down, common dependency', ->
    Given ->
      @expectedPath = 'node_modules/fake2/node_modules/common-dep'
      @fileName = 'common-dep'
      @callers = [ 'fake2' ]
    Then verifyResult

  describe '2 modules down, common dependency', ->
    Given ->
      @expectedPath ='node_modules/fake2/node_modules/common-dep'
      @fileName = 'common-dep'
      @callers = [ 'fake2', 'fake3' ]
    Then verifyResult

  describe '2 modules down, not found', ->
    Given ->
      @fileName = 'nonExisting'
      @callers = [ 'fake2', 'fake3' ]
    Then -> @error?
