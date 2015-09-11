var findModule = require('./dist/find-module');
var getConfigPaths = require('./dist/get-conf-paths');

exports.fromConfig = require('./dist/load-config');
exports.fromNodeConfig = require('./dist/load-node-config');
exports.Container = require('./dist/container');
exports.getConfigPaths = getConfigPaths(findModule.path, findModule.instance);
exports.evaluateType = require('./dist/evaluate-type');
