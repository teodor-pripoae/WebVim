window.WebVim = {}
merge = (obj1, obj2)->
  obj3 = {}
  for key, value of obj1
    obj3[key] = value

  for key, value of obj2
    obj3[key] = value

  return obj3

class Character
  constructor: (evt) ->
    @symbol = @convertToSymbol(evt.keyCode, evt.shiftKey)

    @specialKeys = []

    @shift(evt.shiftKey)
    @alt(evt.altKey)
    @ctrl(evt.ctrlKey)
  convertToSymbol: (keyCode, shift) ->
    generalConvertions = {
      '8,0': '<BS>',
      '9,0': '<Tab>',
      '13,0': '<CR>',
      '27,0': '<ESC>',
      '32,0': '<Space>',
      '33,0': '<PageUp>',
      '34,0': '<PageDown>',
      '35,0': '<End>',
      '36,0': '<Home>',
      '37,0': '<LeftArrow>',
      '38,0': '<UpArrow>',
      '39,0': '<RightArrow>',
      '40,0': '<DownArrow>',
      '45,0': '<Insert>',
      '46,0': '<Del>',
      '188,0': ',',
      '188,1': '<',
      '190,0': '.',
      '190,1': '>',
      '191,0': '/',
      '191,1': '?',
      '192,0': '`',
      '192,1': '~',
      '219,0': '['
      '219,1' 

    }

    
  shift: (value = undefined) ->
    if value?
      @specialKeys[0] = value
    else
      @specialKeys[0]
  
  alt: (value = undefined) ->
    if value?
      @specialKeys[0] = value
    else
      @specialKeys[0]

  ctrl: (value = undefined) ->
    if value?
      @specialKeys[0] = value
    else
      @specialKeys[0]





class Commander
  constructor: (@currentViewPortId = undefined ) ->
    @viewPorts = {}
    @viewPortCount = 0

    $(document).click @handleDocumentClick
    $(document).keypress @handleDocumentKeyPress

  handleDocumentKeyPress: (evt) =>
    evt.stopPropagation()
    evt.preventDefault()
    if @currentViewPortId
      @viewPorts[@currentViewPortId].handleKeyPress(evt)

  handleDocumentClick: (evt) =>
    if $(evt.target).hasClass('.vim')
      viewPortId = $(evt.target).attr 'id'
      @changeViewPortById viewPortId
      return true

    vim = $(evt.target).parents '.vim'

    if vim.length
      viewPortId = vim.attr 'id'
      @changeViewPortById viewPortId
      return true

    #clicked outside the vim box. Should disable vim now
    @viewPorts[@currentViewPortId].deselect()
    @currentViewPortId = undefined


  changeViewPortById: (id) ->
    if @currentViewPortId
      @viewPorts[@currentViewPortId].deselect()
    
    @currentViewPortId = id

    @viewPorts[@currentViewPortId].select()
 
  register: (viewPort) ->
    id = ++ @viewPortCount
    id = "vim-viewport-#{id}"

    @viewPorts[id] = viewPort

    return id

window.WebVim.commander = new Commander()

class KeyMapper
  constructor: () ->
    @maps = {}
  
  addKeyMapper: (keyMapper) ->
    @maps = merge keyMapper.maps, @maps

  setMap: (key, fnc) ->
    @maps[key] = fnc

  getMap: (key) ->
    @maps[key]

  hasMap: (key) ->
    if @maps[key]? then true else false
   
  deleteMap: (key) ->
    delete @maps[key]

class MovementKeyMapper extends KeyMapper
  constructor: () ->
    super()
    @setMap "h", "moveLeft"
    @setMap "j", "moveDown"
    @setMap "k", "moveUp"
    @setMap "l", "moveRight"


class CommandKeyMapper extends KeyMapper
  constructor: () ->
    super()

    @addKeyMapper new MovementKeyMapper()

    @setMap "t", "test"


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


class Buffer
  constructor: (data) ->
    @viewPorts = {}
    @data = [""]

  parseData: (data) ->
    @data = data.split("\n")
    for id, viewPort of  @viewPorts
      setTimeout( () ->
        viewPort.handleLineChange(0,viewPort.rows - 1)
      
      ,0)

  open: (data) ->
    @parseData(data)

  addViewPort: (viewPort) ->
    @viewPorts[viewPort.id] = viewPort

  deleteViewPort: (viewPort) ->
    delete @viewPorts[viewPort.id]

  propagateLineChange: (x, y = undefined) ->
    y = x if not y

    for id, viewPort of  @viewPorts
      viewPort.handleLineChange(x,y)

  deleteLines:  (x, y = undefined) ->
    x = 0 unless x > 0
    y = x unless y
    
    diff = (y-x+1)
    length = @data.length

    @data[x..] = @data[(y+1)..]

    @propagateLineChange x, length - 1

  getLine: (x) ->
    if (x >= @data.length)
      ""
    else
      @data[x]

  getLineCount: () ->
    @data.length - 1



class ViewPort
  constructor: (@elem, @rows=24, @columns=80) ->
    @currentMode = 'command'
    @currentKeySequence = ""

    @modes = {}
    @modes['command'] = new CommandKeyMapper()
    
    @functionDatabase = new FunctionDataBase(this)

    @elem = $(@elem)
    @elem.addClass('vim')
    
    @id = window.WebVim.commander.register this
    @elem.attr 'id', @id

    #Create the needed html structure
    #
    @elem.empty()
    @elem.append webvim.viewport {rows: 24, columns: 80, idPrefix: @id}

    #Set up a Buffer
    
    @buffer = new Buffer()

    @buffer.addViewPort this
    @buffer.open("Ana are mere si pere")

    #Set up cursor   
    @cursorX = 1
    @cursorY = 1
    @moveCursorTo(@cursorX, @cursorY)

  changeMode: (mode) ->
    @currentMode = mode


  select: () ->
    console.log "Focus"

  deselect: () ->
    console.log "Am fost deselectat"

  constructCharId: (x,y) ->
    "##{@id}-character-#{x}-#{y}"

  constructLineId: (x) ->
    "##{@id}-line-#{x}"

  removeCursor: () ->
    @elem.find('.cursor').removeClass('cursor')

  moveCursorTo: (@cursorX, @cursorY) ->
    @removeCursor()
    @elem.find(@constructCharId @cursorX, @cursorY ).addClass 'cursor'

  handleKeyPress: (evt) ->
    if evt.keyCode == 17 or evt.keyCode == 18 or evt.keyCode == 16
      return
    @currentKeySequence += String.fromCharCode(evt.keyCode)
    console.log evt.keyCode, String.fromCharCode(evt.keyCode)
    console.log evt
    console.log @currentKeySequence


    if @modes[@currentMode].hasMap(@currentKeySequence)
      @functionDatabase.callFunction( @modes[@currentMode].getMap @currentKeySequence)
      @currentKeySequence = ""
      
     


  handleLineChange: (x, y) ->
    for line in [x..y]
      @updateLine(line)

  updateLine: (line) ->
    lineElem = @elem.find(@constructLineId(line))

    lineElem.find('span').html('&nbsp')

    data = @buffer.getLine(line)
    len = Math.max data.length, @columns
    
    for column in [0..len]
      lineElem.find(@constructCharId line, column ).html(data[column])

$(document).ready ()->
  window.x = new ViewPort $('.vim')
