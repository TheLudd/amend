ModuleNotFound = require './ModuleNotFound'
getArguments = require './get-arguments'

construct = (c, args) ->
  class F
    constructor: -> c.apply @, args
  F.prototype = c.prototype
  return new F()

runFactory = (factory, args) ->
  factory.apply null, args

throwNotFound = (name, parent) ->
  throw new ModuleNotFound name, parent

module.exports = class Container
  constructor: (conf = {}, @_parents = []) ->
    @_modules = conf.modules || {}
    @_registrations = {}
    @_instances = {}

  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    @_register 'factory', name, func

  value: (name, value) -> @_register 'value', name, value

  class: (name, constructor) ->
    throw new TypeError 'A constructor must be a function' unless constructor instanceof Function
    @_register 'class', name, constructor

  get: (name) ->
    throwNotFound name unless @isRegistered name
    registeredAt = @_registeredAt(name)
    if registeredAt == 'local'
      @_instantiate name unless @_instances[name]?
      return @_instances[name]
    else
      return @_parents[registeredAt].get(name)

  _registeredAt: (name) ->
    if @_registrations[name]?
      return 'local'
    else
      for p in @_parents
        if p._registeredAt(name)?
          parentIndex = _i
      return parentIndex

  isRegistered: (name) -> @_registeredAt(name) != undefined

  getArguments: (name) ->
    if @_modules[name]?
      @_modules[name]
    else
      getArguments @_registrations[name].value

  loadAll: ->
    p.loadAll() for p in @_parents
    Object.keys(@_registrations).forEach (name) =>
      @_instantiate name unless @_instances[name]?

  _register: (type, name, value) -> @_registrations[name] = value: value, type: type

  _instantiate: (name, parent) ->
    module = @_registrations[name]
    throwNotFound name, parent unless module?
    type = module.type
    value = module.value
    instance = if type == 'value' then value else @_instantiateWithDependencies name, value, type
    @_instances[name] = instance
    return instance

  _instantiateWithDependencies: (name, value, type) ->
    args = @getArguments name

    dependencies = args.map (depName) =>
      registeredAt = @_registeredAt(depName)
      if registeredAt == 'local'
        @_instances[depName] || @_instantiate depName, name
      else if registeredAt?
        @_parents[registeredAt].get(depName)
      else
        throwNotFound depName, name

    return runFactory value, dependencies if type == 'factory'
    return construct value, dependencies if type == 'class'
