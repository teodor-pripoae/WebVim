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
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY - 1

  moveRight: (viewport) ->
    viewport.moveCursorTo viewport.cursorX, viewport.cursorY + 1

  moveUp: (viewport) ->
    viewport.moveCursorTo viewport.cursorX - 1, viewport.cursorY

  moveDown: (viewport) ->
    viewport.moveCursorTo viewport.cursorX + 1, viewport.cursorY

class GlobalFunctionDatabase extends BaseFunctionDataBase
  changeMode: (viewPort, mode) ->
    viewPort.changeMode(mode)

class InsertFunctionDatabase extends BaseFunctionDataBase
  insert: (viewPort, letter) ->
    viewPort.buffer.insertAt viewPort.cursorX, viewPort.cursorY, letter
    viewPort.moveCursorTo viewPort.cursorX, viewPort.cursorY + 1
    
  insertSpace: (viewPort) ->
    @insert(viewPort, ' ')
    
  insertNewLine: (viewPort) ->
    viewPort.buffer.addNewLine viewPort.cursorX, viewPort.cursorY
    viewPort.moveCursorTo viewPort.cursorX + 1, 0
  
  deleteChar: (viewPort) ->

    if viewPort.cursorY == 0 #We are the begining of the line and are deleting the newline char
      if viewPort.cursorX == 0 #Nothing do delete
        return true

      lineLength = viewPort.buffer.getLine(viewPort.cursorX).length

      viewPort.buffer.mergeLines viewPort.cursorX - 1, viewPort.cursorX

      viewPort.moveCursorTo viewPort.cursorX - 1, viewPort.buffer.getLine(viewPort.cursorX - 1).length - lineLength
      return true

    viewPort.buffer.deleteOnLineAt viewPort.cursorX, viewPort.cursorY - 1
    viewPort.moveCursorTo viewPort.cursorX, viewPort.cursorY - 1

      
class FunctionDataBase extends BaseFunctionDataBase
  constructor: (viewport)->
    super(viewport)
    @addFunctionDataBase new MovementFunctionDatabase()
    @addFunctionDataBase new GlobalFunctionDatabase()
    @addFunctionDataBase new InsertFunctionDatabase()
    
  test: () ->
    alert "merge"
