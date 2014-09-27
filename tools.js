var annotate = require('./dist/annotate');

module.exports = {
  annotate: function (container, out) {
    out.write(JSON.stringify(annotate(container)));
    out.write('\n');
  }
};
