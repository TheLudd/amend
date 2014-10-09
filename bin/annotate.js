#!/usr/bin/env node
(function() {
  var annotate, conf, di, fileName, fromConfig, path;

  fromConfig = require('..').fromConfig;

  annotate = require('../tools').annotate;

  fileName = process.argv[2];

  path = [process.cwd(), fileName].join('/');

  conf = require(path);

  di = fromConfig(conf);

  annotate(di, process.stdout);

}).call(this);
