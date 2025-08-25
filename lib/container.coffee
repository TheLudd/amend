debug = require('debug')('amend:container')
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
    @_modules = conf.modules || conf
    @_registrations = {}
    @_instances = {}
    debug 'container created with %d parents', @_parents.length
    debug 'initial modules config: %o', @_modules

  factory: (name, func) ->
    throw new Error 'A factory must be a function' unless func instanceof Function
    debug 'registering factory: %s', name
    @_register 'factory', name, func

  value: (name, value) ->
    debug 'registering value: %s (type: %s)', name, typeof value
    @_register 'value', name, value

  class: (name, constructor) ->
    throw new TypeError 'A constructor must be a function' unless constructor instanceof Function
    debug 'registering class: %s', name
    @_register 'class', name, constructor

  spread: (obj) ->
    debug 'spreading object with keys: %j', Object.keys(obj)
    @value(k, v) for k, v of obj

  get: (name) ->
    debug 'getting dependency: %s', name
    throwNotFound name unless @isRegistered name
    registeredAt = @_registeredAt(name)
    debug 'dependency "%s" registered at: %s', name, registeredAt
    if registeredAt == 'local'
      unless @_isInstantiated(name)
        debug 'instantiating local dependency: %s', name
        @_instantiate name
      else
        debug 'reusing existing instance: %s', name
      return @_instances[name]
    else
      debug 'delegating to parent container for: %s', name
      return @_parents[registeredAt].get(name)

  _isInstantiated: (name) -> @_instances.hasOwnProperty(name)

  _registeredAt: (name) ->
    if @_registrations[name]?
      return 'local'
    else
      for p, i in @_parents
        if p._registeredAt(name)?
          parentIndex = i
      return parentIndex

  isRegistered: (name) -> @_registeredAt(name) != undefined

  getRegistrations: ->
    if @_parents.length == 0
      return @_registrations

    all = (p.getRegistrations() for p in @_parents)
    all.push @_registrations
    all.reduce (acc, item) ->
      Object.keys(item).forEach (key) -> acc[key] = item[key]
      return acc
    , {}

  getArguments: (name) ->
    if @_modules[name]?
      @_modules[name]
    else
      getArguments @_registrations[name].value

  loadAll: ->
    debug 'loading all dependencies'
    debug 'loading parent containers first'
    p.loadAll() for p in @_parents
    registrations = Object.keys(@_registrations)
    debug 'loading %d local registrations: %j', registrations.length, registrations
    Object.keys(@_registrations).forEach (name) =>
      unless @_isInstantiated(name)
        debug 'loading: %s', name
        @_instantiate name

  shutdown: ->
    instances = Object.keys(@_instances)
    debug 'shutting down %d instances: %j', instances.length, instances
    Object.keys(@_instances).forEach (key) =>
      if @_instances[key]?.__amendShutdown?
        debug 'calling shutdown hook for: %s', key
        @_instances[key].__amendShutdown()
    debug 'shutting down parent containers'
    p.shutdown() for p in @_parents

  _register: (type, name, value) -> @_registrations[name] = value: value, type: type

  _instantiate: (name, parent) ->
    debug 'instantiating: %s (requested by: %s)', name, parent || 'root'
    module = @_registrations[name]
    throwNotFound name, parent unless module?
    type = module.type
    value = module.value
    debug 'instantiating "%s" as type: %s', name, type
    instance = if type == 'value'
      debug 'returning value directly for: %s', name
      value
    else
      debug 'instantiating with dependencies for: %s', name
      @_instantiateWithDependencies name, value, type
    @_instances[name] = instance
    debug 'cached instance for: %s', name
    return instance

  _instantiateWithDependencies: (name, value, type) ->
    args = @getArguments name
    debug 'resolving %d dependencies for "%s": %j', args.length, name, args

    dependencies = args.map (depName) =>
      debug 'resolving dependency: %s for %s', depName, name
      registeredAt = @_registeredAt(depName)
      if registeredAt == 'local'
        if @_isInstantiated(depName)
          debug 'reusing cached dependency: %s', depName
          @_instances[depName]
        else
          debug 'instantiating local dependency: %s', depName
          @_instantiate depName, name
      else if registeredAt?
        debug 'delegating dependency "%s" to parent %d', depName, registeredAt
        @_parents[registeredAt].get(depName)
      else
        throwNotFound depName, name

    debug 'invoking %s "%s" with %d dependencies', type, name, dependencies.length
    return runFactory value, dependencies if type == 'factory'
    return construct value, dependencies if type == 'class'
