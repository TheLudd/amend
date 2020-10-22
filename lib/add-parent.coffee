module.exports = (
  findModule
  populateDI
) ->

  addParent = (di, opts) ->
    { parentSpec, childCallers = [], base } = opts
    { configFile, nodeModule } = parentSpec
    callers = childCallers.concat nodeModule
    conf = findModule(Object.assign({}, opts, { base, fileName: configFile, callers }))
    conf.parents?.forEach (p) ->
      innerOpts = Object.assign {}, opts,
        base: base
        parentSpec: p
        childCallers: callers
      addParent(di, innerOpts)

    populateOpts = Object.assign {}, opts,
      base: base
      modules: conf.modules
      callers: callers
    populateDI(di, populateOpts)
