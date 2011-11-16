class ViewPort
  constructor: (@elem, @rows=24, @columns=80) ->
    @currentKeySequence = ""

    @modes = {}
    @modes['Command'] = new CommandKeyMapper()
    @modes['Insert'] = new InsertKeyMapper()
    
    @functionDatabase = new FunctionDataBase(this)

    @elem = $(@elem)
    @elem.addClass('vim')
    
    @id = window.WebVim.commander.register this
    @elem.attr 'id', @id

    #Create the needed html structure
    #
    @elem.empty()
    @elem.append webvim.viewport {rows: 24, columns: 80, idPrefix: @id}
    
    @commandLine = @elem.find @constructCommandId()
    
    @changeMode 'Command'
    
    #Set up a Buffer
    
    @buffer = new Buffer()

    @buffer.addViewPort this
    @buffer.open("Ana are mere si pere")

    #Set up cursor   
    @cursorX = 1
    @cursorY = 1
    @moveCursorTo(@cursorX, @cursorY)

  changeMode: (mode) ->
    @commandLine.text mode
    @currentMode = mode

  select: () ->
    console.log "Focus"

  deselect: () ->
    console.log "Am fost deselectat"
    
  constructCommandId: () ->
    "##{@id}-command-line"
    
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
    if evt.keyCode == 17 or evt.keyCode == 18 or evt.keyCode == 16 or evt.keyCode == 91
      return
      
    char = new Character(evt)
    console.log evt.keyCode 
    @currentKeySequence += char.symbol
    console.log @currentKeySequence

    if @modes[@currentMode].hasMap(@currentKeySequence)
      @functionDatabase.callFunction( @modes[@currentMode].getMap @currentKeySequence)
      @currentKeySequence = ""
      return true

    if char.symbol == '<ESC>'
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
