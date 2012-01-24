window.WebVim.History = {}

class Commit
  constructor: (@buffer)->
    @operations = []

  addOperation: (operation) ->
    @operations.push operation

  addInsertOperation: (x, values) ->
    if typeof values == "string"
      length = 1
    else
      length = values.length

    @addOperation {
      upFunction: "insertLines"
      upData: [x, values]
      downFunction: "deleteLines"
      downData: [x, x + length - 1]
    }

  addDeleteOperation: (x, y) ->
    @addOperation {
      upFunction: "deleteLines"
      upData: [x, y]
      downFunction: "insertLines"
      downData: [x, @buffer.data[x..y]]
    }


  up: () ->
    for op in @operations
      @buffer[op.upFunction].apply @buffer, op.upData

  down: () ->
    #Apparently there is no easy way to traverse an array in reverse order
    #Thus implementing it in Javascript
    `for (var i = this.operations.length - 1; i>=0 ; i--){
       var op = this.operations[i];
       this.buffer[op.downFunction].apply(this.buffer, op.downData);
    }`
    return true

window.WebVim.History.Commit = Commit

class History
  constructor: (@buffer) ->
    @commits = []
    @currentCommit = undefined
    @undoneCommits = []
    @extendRecording = 0
    @isRecording = 0

  stopRecording: ()->
    @isRecording--

  startRecording: ()->
    @isRecording++ unless @isRecording == 0

  addCommit: (commit) ->
    if @isRecording == 0
      @commits.push commit
      @currentCommit = commit
      @undoneCommits = []

  undo: (count = 1) ->
    @stopRecording()
  
    while count and @commits.length
      commit = @commits.pop()
      @undoneCommits.push commit
      @currentCommit = @commits[@commits.length - 1]
      commit.down()

      count--

    @startRecording()

  redo: (count = 1) ->
    @stopRecording()
  
    while count and @undoneCommits.length
      commit = @undoneCommits.pop()
      @commits.push commit
      @currentCommit = @commits[@commits.length - 1]
      commit.up()

      count--

    @startRecording()

window.WebVim.History.History = History
