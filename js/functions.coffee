class BaseFunctionDataBase

  constructor: (@viewPort) ->

  hasFunction: (fncName) ->
    if this.__proto__[fncName]? then true else false

  callFunction: (name) ->
    this[name](@viewPort)

  addFunction: (name, fnc) ->
    this.__proto__[name] = fnc
  
  addFunctionDataBase: (functionDB) ->
    this.__proto__ = merge functionDB.__proto__, this.__proto

class MovementFunctionDatabase extends BaseFunctionDataBase
  moveLeft: (viewport) ->
    viewport.cursorY -= 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

  moveRight: (viewport) ->
    viewport.cursorY += 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

  moveUp: (viewport) ->
    viewport.cursorX += 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

  moveDown: (viewport) ->
    viewport.cursorX -= 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

class GlobalFunctionDatabase extends BaseFunctionDataBase
  commandMode: (viewPort) ->
    viewPort.changeMode('command')

class FunctionDataBase extends BaseFunctionDataBase
  constructor: (viewport)->
    super(viewport)
    @addFunctionDataBase new MovementFunctionDatabase()

  test: () ->
    alert "merge"


