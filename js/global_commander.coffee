class Commander
  constructor: (@currentViewPortId = undefined ) ->
    @viewPorts = {}
    @viewPortCount = 0

    $(document).click @handleDocumentClick
    $(document).keydown @handleDocumentKeyPress

  handleDocumentKeyPress: (evt) =>
    evt.stopPropagation()
    evt.preventDefault()
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

