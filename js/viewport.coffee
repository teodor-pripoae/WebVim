class CharRenderer
  constructor: (@viewPort) ->

  parseChar: (char) ->
    if char == ' '
      char = '&nbsp'

    if char == "\t"
      @output = ["&nbsp", '&nbsp', '&nbsp', '&nbsp']
    else
      @output = [char]
  
    @size = @output.length

  
  render: (char, line, startPosition, dataX, dataY) ->
    @parseChar(char)

    for i in [startPosition..(startPosition + @size - 1)]
      if i < @viewPort.startY or i >= @viewPort.startY + @viewPort.columns
        continue

      y = i - @viewPort.startY

      @viewPort.elem.find(@viewPort.constructCharId line, y)
        .attr("dataX", dataX)
        .attr("dataY", dataY)
        .html(@output[i - startPosition])

    return @size
    
class ViewPort
  constructor: (@elem, @rows=24, @columns=80) ->
    @currentKeySequence = ""
    @lastKeyPress = new Date()

    @modes = {}
    @modes['Command'] = new CommandKeyMapper()
    @modes['Insert'] = new InsertKeyMapper()
    
    @functionDatabase = new FunctionDataBase(this)

    @charRenderer = new CharRenderer(this)

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

    #Set up a 

    #Set up cursor
    @startX = 0
    @startY = 0

    @cursorX = 0
    @cursorY = 0

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

  redraw: () ->
    for i in [0..(@rows-1)]
      @updateLine(i)

  getCursorDataX: () ->
    rez = parseInt @elem.find(@constructCharId @cursorX - @startX, @cursorY - @startY).attr("dataX")
    return if isNaN rez then undefined else rez
    
  getCursorDataY: () ->
    rez = parseInt @elem.find(@constructCharId @cursorX - @startX, @cursorY - @startY).attr("dataY")
    return if isNaN rez then undefined else rez


  moveCursorToData: (dataX, dataY) ->
    ###
    re = /^vim-viewport-\d+-character-(\d+)-(\d+)/
  
    sorted_elems = @elem.find("span[dataX=\"#{dataX}\"][dataY=\"#{dataY}\"]").sort (a, b) ->
      dataA = a.attr('id').match re
      dataB = a.attr('id').match re

      return dataA[1] - dataB[1] unless dataA[1] == dataA[2]
      return dataA[2] - dataB[2]
    try
      data = $(sorted_elems[0]).attr('id').match re
      @moveCursorTo @startX + parseInt(data[1]), @startY parseInt(data[2])
    catch error # The element doesn't exist
      @moveCursorTo dataX, dataY
    ###
    if @dataPosition[dataX][dataY] is  undefined
      console.warn "Data Position fail #{dataX} #{dataY}"
    else
      @moveCursorTo dataX, @dataPosition[dataX][dataY]
 
      
  moveCursorTo: (@cursorX, @cursorY) ->
    @removeCursor()

    @cursorX = 0 if @cursorX < 0
    @cursorY = 0 if @cursorY < 0

    oldStartX = @startX
    oldStartY = @startY

    # move the viewport so that it contains the cursor
    if @cursorX < @startX
      @startX = @cursorX

    if @cursorX >= @startX + @rows
      @startX = @cursorX - @rows + 1

    while @cursorY < @startY
      @startY -= (@columns - @columns % 2) / 2

    @startY = 0 if @startY < 0

    while @cursorY >= @startY + @columns
      @startY += (@columns - @columns % 2) / 2

    if @startX != oldStartX or @startY != oldStartY
      @redraw()
      console.log "Start-urile", @startX, @startY

    @elem.find(@constructCharId @cursorX - @startX, @cursorY - @startY ).addClass 'cursor'

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

  reset: () ->
    @startX = 0
    @startY = 0

    @cursorX = 0
    @cursorY = 0

    @elem.find("span.char").html("&nbsp;")
    
    @dataPosition = []

  handleLineChange: (x, y) ->
    for line in [x..y]
      @updateLine(line)

  updateLine: (dataLine) ->
    if dataLine < @startX or dataLine >= @startX + @rows
      return
    else
      line = dataLine - @startX

    @elem.find(@constructLineId(line)).find('span').html('&nbsp')

    data = @buffer.getLine(dataLine)
    len = data.length

    if @dataPosition[dataLine] is undefined
      @dataPosition[dataLine] = []

    position = 0
    for column in [0..(len - 1)]
      @dataPosition[dataLine][column] = position
      position += @charRenderer.render data[column], line, position, line, column
    # add a white space as the trailing character
    @dataPosition[dataLine][column] = position
    @charRenderer.render ' ', line, position, line, column
      
window.WebVim.ViewPort = ViewPort
