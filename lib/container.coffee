getArguments = require './get-arguments'

construct = (c, args) ->
  class F
    constructor: -> c.apply @, args
  F.prototype = c.prototype
  return new F()

runFactory = (factory, args) ->
  factory.apply null, args

module.exports = class Container

  constructor: ->
    @factories = {}
    @instances = {}
    @constructors = {}

  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    @factories[name] = func

  value: (name, value) -> @instances[name] = value

  class: (name, constructor) ->
    throw new TypeError 'A constructor must be a function' unless constructor instanceof Function
    @constructors[name] = constructor

  get: (name) ->
    throw new Error 'Could not find any module with name ' + name unless @isRegistered name
    @_instantiate name unless @instances[name]?
    return @instances[name]

  isRegistered: (name) ->
    @factories[name]? || @constructors[name]? || @instances[name]?

  getArguments: (name, type) -> getArguments @_getFunction name, type

  _instantiate: (name) ->
    type = @_getType name
    func = @_getFunction name, type
    args = @getArguments name, type

    dependencies = args.map (d) =>
      if @instances[d]? then @instances[d] else @_instantiate d

    if type == 'factory'
      instance = runFactory func, dependencies
    else
      instance = construct func, dependencies

    @instances[name] = instance
    return instance

  _getFunction: (name, type = @_getType(name)) ->
    if type == 'factory' then @factories[name] else @constructors[name]

  _getType: (name) -> if @factories[name]? then 'factory' else 'class'
