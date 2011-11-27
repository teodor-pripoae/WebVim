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
    
  insertAt: (x, y, value) ->
    if @data.length <= x
      cnt = x - @data.length + 1
      for i in [1..cnt]
        @data.push ""
        
    if @data[x].length < y
      cnt = y - @data[x].length
      for i in [1..cnt]
        @data[x] += " "
        
    @data[x] = @data[x][0..y-1] + value + @data[x][y..]
    
    @propagateLineChange (x)  

  getLine: (x) ->
    if (x >= @data.length)
      ""
    else
      @data[x]

  getLineCount: () ->
    @data.length - 1
    
  addNewLine: (x) ->
    @data = @data[..x].concat([""]).concat @data[x+1..]
    @propagateLineChange(x + 1, @data.length - 1)
    console.log @data
  
  deleteOnLineAt: (x, y1, y2 = undefined) ->
    y2 = y1 unless y2?

    @data[x] = @data[x][..(y1-1)] + @data[x][(y2+1)..]

    @propagateLineChange(x)
    
    
  

