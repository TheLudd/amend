function isLocal(path) {
  return path[0] === '.';
}

function getRequrePath(val) {
  if (typeof val === 'string') {
    return val;
  } else {
    return val.require;
  }
}

module.exports = function(b, opts) {
  function shouldInclude(key, path) {
    var includeExternal = opts.includeExternal || [];
    return isLocal(path) ||
      bundleExternal ||
      includeExternal.indexOf(key) !== -1;
  }

  var bundleExternal = opts.bundleExternal !== false;
  var modules = opts.modules;
  Object.keys(modules).forEach(function(key) {
    var path = getRequrePath(modules[key]);
    if (shouldInclude(key, path)) {
      b.require(path);
    }
  });
};
