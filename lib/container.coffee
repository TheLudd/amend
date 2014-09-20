getArguments = require './get-arguments'

module.exports = class Container

  _construct: (c, args) ->
    dependencies = args.map (d) =>
        if @instances[d]? then  @instances[d] else @_instantiate d
    class F
      constructor: ->
        c.apply @, dependencies
    F.prototype = c.prototype
    return new F()

  _instantiate: (name) ->
    factory = @factories[name]
    constructor = @constructors[name]
    if factory?
      dependencies = getArguments factory if factory?
    else
      dependencies = getArguments constructor

    if dependencies.length
      instantiatedDependencies = dependencies.map (d) =>
        if @instances[d]? then  @instances[d] else @_instantiate d
      if factory?
        instance = factory.apply null, instantiatedDependencies
      else
        instance = @_construct constructor, dependencies
    else
      if factory?
        instance = factory.call()
      else
        instance = @_construct constructor, dependencies

    @instances[name] = instance
    return instance

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
    if @instances[name]?
      return @instances[name]
    else if @factories[name]? || @constructors[name]?
      @_instantiate name unless @instances[name]?
      return @instances[name]
    else
      throw new Error 'Could not find any module with name ' + name
