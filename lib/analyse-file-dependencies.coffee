{ basename, extname } = require('path')
{ parse } = require('@babel/parser')
{
  prop,
  isNil,
  map,
  mergeAll,
  objOf,
  pathEq,
  find,
} = require('ramda')
fsExtra = require('fs-extra')

functionTypes = new Set([
  'FunctionDeclaration',
  'FunctionExpression',
  'ArrowFunctionExpression',
])

isFunction = (statement) -> functionTypes.has(statement.type)

getMainExportValue = (statement) ->
  if statement.type == 'ExpressionStatement' then statement.expression.right else statement.declaration

resolveStatement = (fullBody, statement) ->
  if statement.type == 'Identifier'
  then find(pathEq([ 'id', 'name' ], statement.name), fullBody)
  else statement

getFunctionParameters = (functionNode) -> functionNode.params.map(prop('name'))

isMainExportStatement = (item) ->
  { type } = item

  if type == 'ExpressionStatement' && item.expression.type == 'AssignmentExpression'
    { left } = item.expression
    if left.type == 'MemberExpression' && left.object.name == 'module' && left.property.name == 'exports'
      return true

    return false

  return type == 'ExportDefaultDeclaration'

module.exports = ([ name, path ]) ->
  return fsExtra.readFile(path, 'utf-8')
    .then((code) ->
      ast = parse(code, { sourceType: 'unambiguous', plugins: [ 'jsx' ] })
      { body } = ast.program
      mainExportStatement = find(isMainExportStatement, body)

      resolvedMainExportStatement =
        resolveStatement(body, getMainExportValue(mainExportStatement))
      if isNil(resolvedMainExportStatement) || !isFunction(resolvedMainExportStatement)
      then {}
      else objOf name, getFunctionParameters(resolvedMainExportStatement)
    )
