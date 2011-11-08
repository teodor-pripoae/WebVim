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

