var R = require('ramda')
var normalize = require('path').normalize;

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

function addAmendModule(b, opts, nodeModule) {
  function shouldInclude(key, path) {
    var includeExternal = opts.includeExternal || [];
    return isLocal(path) ||
      bundleExternal ||
      includeExternal.indexOf(key) !== -1;
  }

  var bundleExternal = opts.bundleExternal !== false;
  var modules = opts.config.modules;
  var parents = opts.config.parents || [];

  parents.forEach(function(p) {
    addParent(b, opts, p);
  })

  Object.keys(modules).forEach(function(key) {
    var modulePath = getRequrePath(modules[key]);
    if (shouldInclude(key, modulePath)) {
      if (nodeModule) {
        modulePath = normalize([ nodeModule, modulePath ].join('/'))
      }
      b.require(modulePath);
    }
  });
}

function addParent(b, opts, parentConf) {
  var base = process.cwd();
  var configFilePath = [ parentConf.nodeModule, parentConf.configFile ].join('/');
  var p = require(configFilePath);
  var parentOpts = R.assoc('config', p, opts)
  b.require(configFilePath)
  addAmendModule(b, parentOpts, parentConf.nodeModule)
}

module.exports = function(b, opts) {
  addAmendModule(b, opts)
};

