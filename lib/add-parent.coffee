module.exports = (
  findModule
  populateDI
) ->

  addParent = (di, base, parentSpec, childCallers) ->
    { configFile, nodeModule } = parentSpec
    callers = childCallers.concat nodeModule
    conf = findModule(base, configFile, callers)
    conf.parents?.forEach (p) ->
      addParent(di, base, p, callers)
    populateDI(di, base, conf.modules, callers)
