window.WebVim = {}

class Commander
  constructor: (@currentViewPortId = undefined ) ->
    @viewPorts = {}
    @viewPortCount = 0

    $(document).click @handleDocumentClick
    $(document).keypress @handleDocumentKeyPress

  handleDocumentKeyPress: (evt) =>
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

  setMap: (key, fnc) ->
    @maps[key] = fnc

  getMap: (key) ->
    @maps[key]

  hasMap: (key) ->
    if @maps[key]? then true else false
   
  deleteMap: (key) ->
    delete @maps[key]

class CommandKeyMapper extends KeyMapper
  constructor: () ->
    super()

    @setMap "t", "test"


class BaseFunctionDataBase

  hasFunction: (fncName) ->
    if this.prototype.fncName then true else false
  call_fnc: (name) ->
    this[name]()

class FunctionDataBase extends BaseFunctionDataBase
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
    
    @functionDatabase = new FunctionDataBase()

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

    @moveCursorTo(1,1)

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
    @currentKeySequence += String.fromCharCode(evt.charCode)

    if @modes[@currentMode].hasMap(@currentKeySequence)
      @functionDatabase.call_fnc( @modes[@currentMode].getMap @currentKeySequence)
      


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
