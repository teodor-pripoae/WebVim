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
  _move: (viewport, dirX, dirY) ->
    dataX = viewport.getCursorDataX()
    dataY = viewport.getCursorDataY()

    dataX += dirX
    dataY += dirY

    if dataX < 0 or dataX >= viewport.buffer.getLineCount()
      return

    if dataY < 0
      return

    if dataY > viewport.buffer.getLine(dataX).length
      if dirX and not dirY
        dataY = viewport.buffer.getLine(dataX).length
      else
        return

    viewport.moveCursorToData(dataX, dataY)

  moveLeft: (viewport) ->
    @_move viewport, 0, -1

  moveRight: (viewport) ->
    @_move viewport, 0, 1
  
  moveUp: (viewport) ->
    @_move viewport, -1, 0

  moveDown: (viewport) ->
    @_move viewport, 1, 0

class GlobalFunctionDatabase extends BaseFunctionDataBase
  changeMode: (viewPort, mode) ->
    viewPort.changeMode(mode)

class InsertFunctionDatabase extends BaseFunctionDataBase
  insert: (viewPort, letter) ->
    dataX = viewPort.getCursorDataX()
    dataY = viewPort.getCursorDataY()

    viewPort.buffer.insertAt dataX, dataY, letter
    viewPort.moveCursorToData dataX, dataY + 1
    
  insertSpace: (viewPort) ->
    @insert(viewPort, ' ')
    
  insertNewLine: (viewPort) ->
    dataX = viewPort.getCursorDataX()
    dataY = viewPort.getCursorDataY()

    viewPort.buffer.addNewLine dataX, dataY
    viewPort.moveCursorToData dataX + 1, 0

  
  deleteChar: (viewPort) ->
    dataX = viewPort.getCursorDataX()
    dataY = viewPort.getCursorDataY()

    if dataY == 0 #We are the begining of the line and are deleting the newline char
      if dataX == 0 #Nothing do delete
        return true

      lineLength = viewPort.buffer.getLine(dataX).length

      viewPort.buffer.mergeLines dataX - 1, dataX
      viewPort.moveCursorToData dataX - 1, viewPort.buffer.getLine(dataX - 1).length - lineLength

      return true

    viewPort.buffer.deleteOnLineAt dataX, dataY - 1
    viewPort.moveCursorToData dataX, dataY - 1

      
class FunctionDataBase extends BaseFunctionDataBase
  constructor: (viewport)->
    super(viewport)
    @addFunctionDataBase new MovementFunctionDatabase()
    @addFunctionDataBase new GlobalFunctionDatabase()
    @addFunctionDataBase new InsertFunctionDatabase()
    
  test: () ->
    alert "merge"
