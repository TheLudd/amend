module.exports = class ModuleNotFound extends Error
  constructor: (@module, @caller) ->
    @message = 'Could not find any module with name ' + module
    @message = @message + ', required from module ' + @caller if @caller?
