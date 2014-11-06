module.exports = class ModuleNotFound extends Error
  constructor: (@module, @parent) ->
    @message = 'Could not find any module with name ' + module
    @message = @message + ', required from module ' + @parent if @parent?
