###
  ViewPorts
  ===========
  
  The ViewPort is the visual part of WebVim.
  It has the following functions:
  
  1. It renders the text in html.
  2. It handles user interaction ( mostly key presses )
  
  Each viewPort has an assigned buffer.
  The buffer will automatcly notify the viewPort when the text has changed.
  
  1. Rendering the html
  -----------------------
  
  The function **handleLineChange** is called by the buffer when the text has changed.
  It passes an interval containing the line that has changed. (Note: some lines in the interval may be unchanged)
  
  The function **updateLine** is responsible for rendering / rerendering a text line. Internally it uses the 
  **CharRenderer** class to render each character .
  
  2. Handleling user interaction
  -------------------------------
  
  The **select** and **deselect** methods are called when the WebVim is selected / deselected.
  
  The **handleKeyPress** is called when a key is pressed.
  The viewPort should resolve any key maps and call the appropiate functions.
  
###
class CharRenderer
  ###
    This class renders a normal char in a viewPort
  ###
  
  constructor: (@viewPort) ->

  parseChar: (char) ->
    ###
      The functions parses a character and returns a vector containing the strings to be added in each column
      Ex:
      
        1. A space is transformed to &nbsp ;
        2. A tab is transformed to a vector of &nbsp ;
    ###
  
    if char == ' '
      char = '&nbsp'

    if char == "\t"
      @output = ["&nbsp", '&nbsp', '&nbsp', '&nbsp']
    else
      @output = [char]
  
    @size = @output.length

  
  render: (char, line, startPosition, dataX, dataY) ->
    ###
      Renders the character **char** on the line **line** starting from position **startPosition**.
      
      The **dataX** and **dataY** values represent the position of the character in the text. This values
      are necessary for finding out on which character the cursor is.
    ###
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
  ###
    Base ViewPort class.
  ###
  
  constructor: (@elem, @rows=24, @columns=80) ->
    ###
      The **elem** value is a JQuery selector for finding the html element that will contain the ViewPort.
      In other words $(elem) will be the container for the ViewPort.
      
      Theoreticaly it should be possible to have a ViewPort class that renders the same html in multiple containers, but this is not tested
      and it all depends on how a JQuery Id based selector works when there are multiple elements with the same Id.
    ###
    
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


    #Set up cursor
    @startX = 0
    @startY = 0

    @cursorX = 0
    @cursorY = 0

    @moveCursorTo(@cursorX, @cursorY)

  changeMode: (mode) ->
    ###
      Changes the command mode.
    ###
    @commandLine.text mode
    @currentMode = mode

  select: () ->
    ###
      Callback for when the ViewPort becomes "focused" ( The html element  is not necessarly focused.
      More details about what "focused" means can be found in the documentation of the WebVim Commander ).
    ###
    console.log "Focus"

  deselect: () ->
    ### 
      Callback for when the viewPort has lost "focus". See the WebVim Commander documentation to see how "focus" if defined.
    ###
    console.log "Am fost deselectat"
    
  constructCommandId: () ->
    ###
      Constructs the Id selector for the command line.
    ###
    
    "##{@id}-command-line"
    
  constructCharId: (x,y) ->
    ###
      Constructs the Id selector for the character on the line **x**, column **y**
    ###
    
    "##{@id}-character-#{x}-#{y}"

  constructLineId: (x) ->
    ###
      Constructs the Id selector for the line **x**
    ###
    "##{@id}-line-#{x}"

  removeCursor: () ->
    ###
      Removes the cursor.
    ###
    @elem.find('.cursor').removeClass('cursor')

  redraw: () ->
    ###
      Rerenders the whole viewPort
    ###
    for i in [0..(@rows-1)]
      @updateLine(i)

  getCursorDataX: () ->
    ###
      Returns the line in the text that coresponds to the current position of the cursor.
    ###
    
    rez = parseInt @elem.find(@constructCharId @cursorX - @startX, @cursorY - @startY).attr("dataX")
    return if isNaN rez then undefined else rez
    
  getCursorDataY: () ->
    ###
      Returns the column in the text that coresponds to the current position of the cursor.
    ###
    
    rez = parseInt @elem.find(@constructCharId @cursorX - @startX, @cursorY - @startY).attr("dataY")
    return if isNaN rez then undefined else rez


  moveCursorToData: (dataX, dataY) ->
   ###
    Moves the cursor to the position corresponding to the character on line **dataX**, column **dataY** of the text.
   ###
   
   if dataX < 0
      dataX = 0

    if dataX >= @buffer.getLineCount()
      dataX = @buffer.getLineCount() - 1

    if dataY < 0
      dataY = 0
      
    if dataY > @buffer.getLine(dataX).length
      dataY = @buffer.getLine(dataX).length

    if @dataPosition[dataX][dataY] is  undefined
      console.warn "Data Position fail #{dataX} #{dataY}"
    else
      @moveCursorTo dataX, @dataPosition[dataX][dataY]
 
      
  moveCursorTo: (@cursorX, @cursorY) ->
    ###
      Moves cursor to a position on the ViewPort.
    ###
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
    ###
      This function is called when a key is pressed. It should record key sequences and try to resolve key maps.
    ###
    
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
    ###
      Resets the viewPort
    ###
    @startX = 0
    @startY = 0

    @cursorX = 0
    @cursorY = 0

    @elem.find("span.char").html("&nbsp;")
    
    @dataPosition = []

  handleLineChange: (x, y) ->
    ###
      This function will be called by the buffer indicating the line interval that has changed in the text.
    ###
    for line in [x..y]
      @updateLine(line)

  updateLine: (dataLine) ->
    ###
      Renders / Rerenders the line **dataLine** from the text.
    ###
    
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
