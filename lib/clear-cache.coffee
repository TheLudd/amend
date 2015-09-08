module.exports = (paths) -> paths.forEach (p) -> delete require.cache[p]


