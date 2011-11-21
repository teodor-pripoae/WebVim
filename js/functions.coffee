class BaseFunctionDataBase

  constructor: (@viewPort) ->

  hasFunction: (fncName) ->
    if this.__proto__[fncName]? then true else false

  callFunction: (name) ->
    if typeof name  == "function"
        name(@viewport)
        
    splited_args = name.split(" ")
    
    name = splited_args[0]
    splited_args[0] = @viewPort
    
    this[name].apply(this, splited_args)
    #this[name](@viewPort)

  addFunction: (name, fnc) ->
    this.__proto__[name] = fnc
  
  addFunctionDataBase: (functionDB) ->
    this.__proto__ = merge functionDB.__proto__, this.__proto__

class MovementFunctionDatabase extends BaseFunctionDataBase
  moveLeft: (viewport) ->
    viewport.cursorY -= 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

  moveRight: (viewport) ->
    viewport.cursorY += 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

  moveUp: (viewport) ->
    viewport.cursorX -= 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

  moveDown: (viewport) ->
    viewport.cursorX += 1
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY

class GlobalFunctionDatabase extends BaseFunctionDataBase
  changeMode: (viewPort, mode) ->
    viewPort.changeMode(mode)

class InsertFunctionDatabase extends BaseFunctionDataBase
  insert: (viewPort, letter) ->
    viewPort.buffer.insertAt viewPort.cursorX, viewPort.cursorY, letter
    viewPort.moveCursorTo viewPort.cursorX, viewPort.cursorY + 1
    
  insertNewLine: (viewPort) ->
    viewPort.buffer.addNewLine viewPort.cursorX
    viewPort.moveCursorTo viewPort.cursorX + 1, 0

      
class FunctionDataBase extends BaseFunctionDataBase
  constructor: (viewport)->
    super(viewport)
    @addFunctionDataBase new MovementFunctionDatabase()
    @addFunctionDataBase new GlobalFunctionDatabase()
    @addFunctionDataBase new InsertFunctionDatabase()
    
  test: () ->
    alert "merge"
