class ViewPort
  constructor: (@elem, @rows=24, @columns=80) ->
    @currentKeySequence = ""
    @lastKeyPress = new Date()

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
    @elem.append webvim.viewport {rows: @rows, columns: @columns, idPrefix: @id}
    
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

    @cursorX = 0 if @cursorX < 0
    @cursorY = 0 if @cursorY < 0

    @elem.find(@constructCharId @cursorX, @cursorY ).addClass 'cursor'

  handleKeyPress: (evt) ->
    if evt.keyCode == 17 or evt.keyCode == 18 or evt.keyCode == 16 or evt.keyCode == 91
      return

    char = new Character(evt)

    now = new Date()

    if now - @lastKeyPress > 1000
      @currentKeySequence = ""

    @lastKeyPress = now

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
      char = if data[column] == ' ' then '&nbsp' else data[column]
      
      if char == String.fromCharCode 9 #it's a tab
        char = ""
        for i in [1..4]
          char += '&nbsp'
          
      lineElem.find(@constructCharId line, column ).html(char)
      
      
window.WebVim.ViewPort = ViewPort
