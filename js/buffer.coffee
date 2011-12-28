class Buffer
  constructor: (data) ->
    @viewPorts = {}
    @data = [""]

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
    
    diff = (y-x+1)
    length = @data.length

    @data[x..] = @data[(y+1)..]

    @propagateLineChange x, length - 1
    
  insertAt: (x, y, value) ->
    if @data.length <= x
      cnt = x - @data.length + 1
      for i in [1..cnt]
        @data.push ""
        
    if @data[x].length < y
      cnt = y - @data[x].length
      for i in [1..cnt]
        @data[x] += " "
    if y == 0
      @data[x] = value + @data[x]
    else
      @data[x] = @data[x][0..y-1] + value + @data[x][y..]
    
    @propagateLineChange x

  getLine: (x) ->
    if (x >= @data.length)
      ""
    else
      @data[x]

  getLineCount: () ->
    @data.length
  
    
  addNewLine: (x, y) ->

    if @data.length <= x
      cnt = x - @data.length + 1
      for i in [1..cnt]
        @data.push ""

    if y == 0
      transport = @data[x]
    else
      transport = @data[x][y..]
    
    @data = @data[..x].concat([transport]).concat @data[x+1..]

    if y == 0
      @data[x] = ""
    else
      @data[x] = @data[x][..y-1]

    @propagateLineChange(x, @data.length - 1)
  
  deleteOnLineAt: (x, y1, y2 = undefined) ->
    y2 = y1 unless y2?

    if y1 == 0
      @data[x] = @data[x][1..]
    else
      @data[x] = @data[x][..(y1-1)] + @data[x][(y2+1)..]

    @propagateLineChange(x)

  mergeLines: (x1, x2) ->
    end = Math.min x2, @data.length

    if x1 >= @data.length
      return true

    for x in [(x1+1) .. x2]
      @data[x1] += @data[x]

    previous_length = @data.length

    @data = @data[..x1].concat @data[x2+1..]

    if typeof @data == "string"
      @data = [@data]

    @propagateLineChange x1, previous_length
    
window.WebVim.Buffer = Buffer
