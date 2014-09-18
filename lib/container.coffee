getArguments = require './get-arguments'

module.exports = class Container

  _instantiate: (name) ->
    factory = @factories[name]
    dependencies = getArguments factory
    if dependencies.length
      instantiatedDependencies = dependencies.map (d) =>
        if @instances[d]?
          @instances[d]
        else
          @_instantiate d
      instance = factory.apply null, instantiatedDependencies
    else
      instance = factory.call()

    @instances[name] = instance
    return instance

  constructor: ->
    @factories = {}
    @instances = {}

  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    @factories[name] = func

  get: (name) ->
    @_instantiate name unless @instances[name]?
    return @instances[name]
