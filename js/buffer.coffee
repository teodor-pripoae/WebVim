###
  This module containts the buffer related classes
###


class Buffer
  ###
    The main role of a buffer is to store and alter the text from a given source.
  ###
  
  constructor: (data) ->
    ###
      data - The initial text with which the buffer is initialized
    ###

    @viewPorts = {}
    @data = [""]
    @history = new window.WebVim.History.History(this)

  parseData: (data) ->
    ###
      This functions parses a raw string and loads it as the text of the buffer.

      data - The string to be parsed
    ###
    
    @data = data.split("\n")
    
    data = @data #To access it in the timeout
    for id, viewPort of  @viewPorts
      setTimeout( () ->
        viewPort.reset()
        viewPort.handleLineChange 0, data.length - 1
      ,0)

  open: (data) ->
    ###
      This function should load the buffer from a given source.
      Currently it only loads data from a string.
    ###
    
    @parseData(data)

  addViewPort: (viewPort) ->
    ###
      Adds a viewPort to the list of viewPorts that will be notified when the buffer's data is changed
    ###
    
    @viewPorts[viewPort.id] = viewPort

  deleteViewPort: (viewPort) ->
    ###
      Deletes a viewPort to the list of viewPorts that will be notified when the buffer's data is changed
    ###
    
    delete @viewPorts[viewPort.id]

  propagateLineChange: (x, y = undefined) ->
    ###
      This function announces the viewPorts of the lines that have changed.
    ###
    
    y = x if not y

    for id, viewPort of  @viewPorts
      viewPort.handleLineChange(x,y)

  deleteLines:  (x, y = undefined) ->
    ###
      Deletes the lines from x to y from the text
      If y is not specified it will default to x
    ###
      
    x = 0 unless x > 0
    y = x unless y

    commit = new window.WebVim.History.Commit(this)
    commit.addDeleteOperation x, y
    
    diff = (y-x+1)
    length = @data.length

    @data[x..] = @data[(y+1)..]

    @history.addCommit commit

    @propagateLineChange x, length - 1

  insertLines: (x, values) ->
    ###
      Inserts lines of text starting on the line x
      values can be a string (if only one line is to be inserted) or an array of strings
    ###

    commit = new window.WebVim.History.Commit(this)

    commit.addInsertOperation x, values

    if typeof values == "string"
      values = [values]
    if x == 0
      @data = values.concat(@data)
    else
      @data =  @data[..(x-1)].concat(values).concat @data[x..]

    @history.addCommit commit

    @propagateLineChange x, @data.length - 1

  delete: (startX, startY, endX, endY) ->
    ###
      Deletes texts from line startX column startY to line endX and column endY
    ###
    
    commit = new window.WebVim.History.Commit(this)
    #computes the changes on the first line
    
    commit.addDeleteOperation startX, startX

    if startY == 0
      beginning = ""
    else
      beginning = @data[startX][..startY-1]

    if endX != startX
      ending = ""
    else
      ending = @data[startX][endY + 1..]

    commit.addInsertOperation startX, beginning + ending

    #delete the lines in between
    
    if endX - startX >= 2
      commit.addDeleteOperation startX + 1, endX - 1
    
    #The last line
    if endX != startX
      commit.addInsertOperation endX, endX
      if endY <= @data[endX].length - 1
        commit.addInsertOperation endX, @data[endX][endY+1..]
    
    @history.addCommit commit

    @history.stopRecording()
    commit.up()
    @history.startRecording()

  insert: (x, y, value) ->
    ###
      Inserts text starting from line x column y
      
      value - should be a string containing the text to be inserted
    ###
    commit = new window.WebVim.History.Commit(this)

    if value == ""
      return

    values = value.split("\n")

    #The first line
    
    commit.addDeleteOperation(x, x)

    if y == 0
      beginning = ""
    else
      beginning = @data[x][..y-1]

    if values.length == 1
      ending = @data[x][y..]
      transport = ""
    else
      ending = ""
      transport = @data[x][y..]

    commit.addInsertOperation x, beginning + values[0] + ending

    #The middle lines
    
    if values.length > 2
      commit.addInsertOperation x+1, values[1..values.length-2]

    #The last line

    if values.length >= 2
      commit.addInsertOperation x + values.length - 1, values[values.length - 1] + transport

    @history.addCommit commit

    @history.stopRecording()
    commit.up()
    @history.startRecording()

  getLine: (x) ->
    ###
      Returns the line x as a string
    ###
    
    if (x >= @data.length)
      ""
    else
      @data[x]
  

  getLineCount: () ->
    ###
      Returns the number of lines.
    ###
    @data.length
  
  mergeLines: (x1, x2) ->
    ###
      Merges the lines from x1 to x2 into a single line
    ###
    
    end = Math.min x2, @data.length

    if x1 >= @data.length
      return true

    commit = new window.WebVim.History.Commit(this)

    commit.addDeleteOperation x1, x2
    commit.addInsertOperation x1, @data[x1..x2].join('')

    previous_length = @data.length

    @history.addCommit commit

    @history.stopRecording()
    commit.up()
    @history.startRecording()

    @propagateLineChange x1, previous_length
    
window.WebVim.Buffer = Buffer
