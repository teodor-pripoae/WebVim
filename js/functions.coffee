class BaseFunctionDataBase

  constructor: (@viewPort) ->

  hasFunction: (fncName) ->
    if this.__proto__[fncName]? then true else false

  callFunction: (name) ->
    if typeof name  == "function"
        name(@viewPort)
        
    splited_args = name.split(" ")
    
    name = splited_args[0]
    splited_args[0] = @viewPort
    
    this[name].apply(this, splited_args)

  addFunction: (name, fnc) ->
    this.__proto__[name] = fnc
  
  addFunctionDataBase: (functionDB) ->
    this.__proto__ = merge functionDB.__proto__, this.__proto__

class MovementFunctionDatabase extends BaseFunctionDataBase
  _move: (viewPort, dirX, dirY) ->
    dataX = viewPort.getCursorDataX()
    dataY = viewPort.getCursorDataY()

    dataX += dirX
    dataY += dirY

    viewPort.moveCursorToData(dataX, dataY)

  moveLeft: (viewPort) ->
    @_move viewPort, 0, -1

  moveRight: (viewPort) ->
    @_move viewPort, 0, 1
  
  moveUp: (viewPort) ->
    @_move viewPort, -1, 0

  moveDown: (viewPort) ->
    @_move viewPort, 1, 0

  moveToHome: (viewPort) ->
    viewPort.moveCursorToData viewPort.getCursorDataX(), 0
  
  moveToEnd: (viewPort) ->
    row = viewPort.getCursorDataX()
    col = viewPort.buffer.getLine(row).length
    viewPort.buffer.insert

class CommandFunctionDatabase extends BaseFunctionDataBase
  insertLineAfter: (viewPort) ->
    row = viewPort.getCursorDataX()
    console.log "in jos"
    col = viewPort.buffer.getLine(row).length

    viewPort.buffer.insert row, col, "\n"
    viewPort.moveCursorToData row + 1, 0
    viewPort.changeMode("Insert")

  insertLineBefore: (viewPort) ->
    row = viewPort.getCursorDataY()
    console.log "in sus"
    
    viewPort.buffer.insert row, 0, "\n"
    viewPort.changeMode("Insert")

class GlobalFunctionDatabase extends BaseFunctionDataBase
  changeMode: (viewPort, mode) ->
    viewPort.changeMode(mode)

class HistoryFunctionDatabase extends BaseFunctionDataBase
  undo: (viewPort) ->
    viewPort.buffer.history.undo()

  redo: (viewPort) ->
    viewPort.buffer.history.redo()

class InsertFunctionDatabase extends BaseFunctionDataBase
  insert: (viewPort, letter) ->
    dataX = viewPort.getCursorDataX()
    dataY = viewPort.getCursorDataY()

    viewPort.buffer.insert dataX, dataY, letter
    if letter == "\n"
      viewPort.moveCursorToData dataX + 1, 0
    else
      viewPort.moveCursorToData dataX, dataY + 1
    
  insertSpace: (viewPort) ->
    @insert(viewPort, ' ')

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

    viewPort.buffer.delete dataX, dataY- 1, dataX, dataY - 1
    viewPort.moveCursorToData dataX, dataY - 1


      
class FunctionDataBase extends BaseFunctionDataBase
  constructor: (viewPort)->
    super(viewPort)
    @addFunctionDataBase new MovementFunctionDatabase()
    @addFunctionDataBase new GlobalFunctionDatabase()
    @addFunctionDataBase new InsertFunctionDatabase()
    @addFunctionDataBase new HistoryFunctionDatabase()
    @addFunctionDataBase new CommandFunctionDatabase()
    
  test: () ->
    alert "merge"
