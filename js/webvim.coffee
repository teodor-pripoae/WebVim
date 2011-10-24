window.WebVim = {}

class Commander
  constructor: (@currentViewPortId = undefined ) ->
    @viewPorts = {}
    @viewPortCount = 0

    $(document).click @handleDocumentClick
    $(document).keypress @handleDocumentKeyPress

  handleDocumentKeyPress: (evt) =>
    if @currentViewPortId
      @viewPorts[@currentViewPortId].handleKeyPress(evt)

  handleDocumentClick: (evt) =>
    if $(evt.target).hasClass('.vim')
      viewPortId = $(evt.target).attr 'id'
      @changeViewPortById viewPortId
      return true

    vim = $(evt.target).parents '.vim'

    if vim.length
      viewPortId = vim.attr 'id'
      @changeViewPortById viewPortId
      return true

    #clicked outside the vim box. Should disable vim now
    @viewPorts[@currentViewPortId].deselect()
    @currentViewPortId = undefined


  changeViewPortById: (id) ->
    if @currentViewPortId
      @viewPorts[@currentViewPortId].deselect()
    
    @currentViewPortId = id

    @viewPorts[@currentViewPortId].select()
 
  register: (viewPort) ->
    id = ++ @viewPortCount
    id = "vim-viewport-#{id}"

    @viewPorts[id] = viewPort

    return id

window.WebVim.commander = new Commander()

class ViewPort
  constructor: (@elem, @rows=24, @columns=80) ->
    @elem = $(@elem)
    @elem.addClass('vim')
    
    @id = window.WebVim.commander.register this
    @elem.attr 'id', @id

    #Create the needed html structure
    #
    @elem.empty()
    @elem.append webvim.viewport {rows: 24, columns: 80, idPrefix: @id}

    #Set up cursor
    
    @moveCursorTo(1,1)


  select: () ->
    console.log "Focus"

  deselect: () ->
    console.log "Am fost deselectat"

  constructCharId: (x,y) ->
    "##{@id}-character-#{x}-#{y}"

  removeCursor: () ->
    @elem.find('.cursor').removeClass('cursor')

  moveCursorTo: (@cursorX, @cursorY) ->
    @removeCursor()
    @elem.find(@constructCharId @cursorX, @cursorY ).addClass 'cursor'
  handleKeyPress: (evt) ->
    console.log evt


$(document).ready ()->
  window.x = new ViewPort $('.vim')
