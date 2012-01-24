class Buffer
  constructor: (data) ->
    @viewPorts = {}
    @data = [""]
    @history = new window.WebVim.History.History(this)

  parseData: (data) ->
    @data = data.split("\n")
    
    data = @data #To access it in the timeout
    for id, viewPort of  @viewPorts
      setTimeout( () ->
        viewPort.reset()
        viewPort.handleLineChange 0, data.length - 1
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

    commit = new window.WebVim.History.Commit(this)
    commit.addDeleteOperation x, y
    
    diff = (y-x+1)
    length = @data.length

    @data[x..] = @data[(y+1)..]

    @history.addCommit commit

    @propagateLineChange x, length - 1

  insertLines: (x, values) ->
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
    if (x >= @data.length)
      ""
    else
      @data[x]
  

  getLineCount: () ->
    @data.length
  
  mergeLines: (x1, x2) ->
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
