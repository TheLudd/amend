var normalize = require('path').normalize;
var findModule = require('./dist/find-module');
var getConfPaths = require('./dist/get-conf-paths')(findModule.path, findModule.instance);

function addAmendModule(b, opts, nodeModule) {
  function shouldInclude(isLocal, key) {
    var includeExternal = opts.includeExternal || [];
    return isLocal ||
      bundleExternal ||
      includeExternal.indexOf(key) !== -1;
  }

  var bundleExternal = opts.bundleExternal !== false;
  var paths = getConfPaths(opts.baseDir, opts.config)
  paths.forEach(function(obj) {
    var key = obj.key;
    var path = obj.path;
    var isLocal = obj.isLocal;
    if (shouldInclude(isLocal, key)) {
      b.require(path);
    }
  });

}

module.exports = function(b, opts) {
  addAmendModule(b, opts)
};

