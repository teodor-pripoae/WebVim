class Character
  constructor: (evt) ->
    @symbol = @convertToSymbol(evt.keyCode, evt.shiftKey)

    @specialKeys = []

    @shift(evt.shiftKey)
    @alt(evt.altKey)
    @ctrl(evt.ctrlKey)

  convertToSymbol: (keyCode, shift) ->
    generalConvertions = {
      '8,0': '<BS>',
      #'9,0': '<Tab>',
      '13,0': '<CR>',
      '27,0': '<ESC>',
      '32,0': ' ',
      '33,0': '<PageUp>',
      '34,0': '<PageDown>',
      '35,0': '<End>',
      '36,0': '<Home>',
      '37,0': '<LeftArrow>',
      '38,0': '<UpArrow>',
      '39,0': '<RightArrow>',
      '40,0': '<DownArrow>',
      '45,0': '<Insert>',
      '46,0': '<Del>',
      '49,1': '!',
      '50,1': '@',
      '51,1': '#',
      '52,1': '$',
      '53,1': '%',
      '54,1': '^',
      '55,1': '&',
      '56,1': '*',
      '57,1': '(',
      '48,1': ')',
      '188,0': ',',
      '188,1': '<',
      '190,0': '.',
      '190,1': '>',
      '191,0': '/',
      '191,1': '?',
      '192,0': '`',
      '192,1': '~',
      '219,0': '[',
      '219,1': '{',
      '220,0': '\\',
      '220,1': '|',
      '221,0': ']',
      '221,1': '}',
      '222,0': "'",
      '222,1': '"',
      '187,0': '=',
      '187,1': '+',
      '189,0': '-',
      '189,1': '_',
      '186,0': ';',
      '186,1': ':',
    }
    console.log keyCode

    shift = if shift then 1 else 0
    # Letter
    if keyCode <= 90 and keyCode >= 65
      if not shift
        return String.fromCharCode(keyCode + 32)
      return String.fromCharCode(keyCode)
    
    keyString =  [keyCode, shift].join ','

    if generalConvertions[keyString]?
      return generalConvertions[keyString]

    return String.fromCharCode(keyCode)

    
  shift: (value = undefined) ->
    if value?
      @specialKeys[0] = value
    else
      @specialKeys[0]
  
  alt: (value = undefined) ->
    if value?
      @specialKeys[0] = value
    else
      @specialKeys[0]

  ctrl: (value = undefined) ->
    if value?
      @specialKeys[0] = value
    else
      @specialKeys[0]

class KeyMapper
  constructor: () ->
    @maps = {}
  
  addKeyMapper: (keyMapper) ->
    @maps = merge keyMapper.maps, @maps

  setMap: (key, fnc) ->
    @maps[key] = fnc

  getMap: (key) ->
    @maps[key]

  hasMap: (key) ->
    if @maps[key]? then true else false
   
  deleteMap: (key) ->
    delete @maps[key]

class LetterMovementKeyMapper extends KeyMapper
  constructor: () ->
    super()
    
    @setMap "h", "moveLeft"
    @setMap "j", "moveDown"
    @setMap "k", "moveUp"
    @setMap "l", "moveRight"
    
class ArrowMovementKeyMapper extends KeyMapper
  constructor: () ->
    super()
    
    @setMap "<UpArrow>",  "moveUp"
    @setMap "<DownArrow>", "moveDown"
    @setMap "<LeftArrow>", "moveLeft"
    @setMap "<RightArrow>", "moveRight"
    @setMap "<Home>", "moveToHome"

class MovementKeyMapper extends KeyMapper
  constructor: () ->
    super()
    
    @addKeyMapper new LetterMovementKeyMapper()
    @addKeyMapper new ArrowMovementKeyMapper()


class CommandKeyMapper extends KeyMapper
  constructor: () ->
    super()

    @addKeyMapper new MovementKeyMapper()
    @setMap "a", "changeMode Insert"
    
class InsertKeyMapper extends KeyMapper
  constructor: () ->
    super()
    
    @setMap "<ESC>", "changeMode Command"
    @setMap "<CR>", "insertNewLine"
    @setMap "<BS>", "deleteChar"
    @setMap " ", "insertSpace"
    
    @addKeyMapper new ArrowMovementKeyMapper()
    
  hasMap: (key) ->
    return true
    
  getMap: (key) ->
    if @maps[key]?
      return super(key)
    return "insert #{ key }"
            


