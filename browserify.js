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
  var bundleExternal = opts.bundleExternal !== false;
  var modules = opts.modules;
  Object.keys(modules).forEach(function(key) {
    var path = getRequrePath(modules[key]);
    if (isLocal(path) || bundleExternal) {
      b.require(path);
    }
  });
};
