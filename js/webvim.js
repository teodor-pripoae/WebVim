(function() {
  var ArrowMovementKeyMapper, BaseFunctionDataBase, Buffer, CharRenderer, Character, CommandKeyMapper, Commander, Commit, FunctionDataBase, GlobalFunctionDatabase, History, HistoryFunctionDatabase, InsertFunctionDatabase, InsertKeyMapper, KeyMapper, LetterMovementKeyMapper, MovementFunctionDatabase, MovementKeyMapper, ViewPort, merge;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.WebVim = {};

  merge = function(obj1, obj2) {
    var key, obj3, value;
    obj3 = {};
    for (key in obj1) {
      value = obj1[key];
      obj3[key] = value;
    }
    for (key in obj2) {
      value = obj2[key];
      obj3[key] = value;
    }
    return obj3;
  };

  CharRenderer = (function() {

    function CharRenderer(viewPort) {
      this.viewPort = viewPort;
    }

    CharRenderer.prototype.parseChar = function(char) {
      if (char === ' ') char = '&nbsp';
      if (char === "\t") {
        this.output = ["&nbsp", '&nbsp', '&nbsp', '&nbsp'];
      } else {
        this.output = [char];
      }
      return this.size = this.output.length;
    };

    CharRenderer.prototype.render = function(char, line, startPosition, dataX, dataY) {
      var i, y, _ref;
      this.parseChar(char);
      for (i = startPosition, _ref = startPosition + this.size - 1; startPosition <= _ref ? i <= _ref : i >= _ref; startPosition <= _ref ? i++ : i--) {
        if (i < this.viewPort.startY || i >= this.viewPort.startY + this.viewPort.columns) {
          continue;
        }
        y = i - this.viewPort.startY;
        this.viewPort.elem.find(this.viewPort.constructCharId(line, y)).attr("dataX", dataX).attr("dataY", dataY).html(this.output[i - startPosition]);
      }
      return this.size;
    };

    return CharRenderer;

  })();

  ViewPort = (function() {

    function ViewPort(elem, rows, columns) {
      this.elem = elem;
      this.rows = rows != null ? rows : 24;
      this.columns = columns != null ? columns : 80;
      this.currentKeySequence = "";
      this.lastKeyPress = new Date();
      this.modes = {};
      this.modes['Command'] = new CommandKeyMapper();
      this.modes['Insert'] = new InsertKeyMapper();
      this.functionDatabase = new FunctionDataBase(this);
      this.charRenderer = new CharRenderer(this);
      this.elem = $(this.elem);
      this.elem.addClass('vim');
      this.id = window.WebVim.commander.register(this);
      this.elem.attr('id', this.id);
      this.elem.empty();
      this.elem.append(webvim.viewport({
        rows: this.rows,
        columns: this.columns,
        idPrefix: this.id
      }));
      this.commandLine = this.elem.find(this.constructCommandId());
      this.changeMode('Command');
      this.buffer = new Buffer();
      this.buffer.addViewPort(this);
      this.buffer.open("Ana are mere si pere");
      this.startX = 0;
      this.startY = 0;
      this.cursorX = 0;
      this.cursorY = 0;
      this.moveCursorTo(this.cursorX, this.cursorY);
    }

    ViewPort.prototype.changeMode = function(mode) {
      this.commandLine.text(mode);
      return this.currentMode = mode;
    };

    ViewPort.prototype.select = function() {
      return console.log("Focus");
    };

    ViewPort.prototype.deselect = function() {
      return console.log("Am fost deselectat");
    };

    ViewPort.prototype.constructCommandId = function() {
      return "#" + this.id + "-command-line";
    };

    ViewPort.prototype.constructCharId = function(x, y) {
      return "#" + this.id + "-character-" + x + "-" + y;
    };

    ViewPort.prototype.constructLineId = function(x) {
      return "#" + this.id + "-line-" + x;
    };

    ViewPort.prototype.removeCursor = function() {
      return this.elem.find('.cursor').removeClass('cursor');
    };

    ViewPort.prototype.redraw = function() {
      var i, _ref, _results;
      _results = [];
      for (i = 0, _ref = this.rows - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        _results.push(this.updateLine(i));
      }
      return _results;
    };

    ViewPort.prototype.getCursorDataX = function() {
      var rez;
      rez = parseInt(this.elem.find(this.constructCharId(this.cursorX - this.startX, this.cursorY - this.startY)).attr("dataX"));
      if (isNaN(rez)) {
        return;
      } else {
        return rez;
      }
    };

    ViewPort.prototype.getCursorDataY = function() {
      var rez;
      rez = parseInt(this.elem.find(this.constructCharId(this.cursorX - this.startX, this.cursorY - this.startY)).attr("dataY"));
      if (isNaN(rez)) {
        return;
      } else {
        return rez;
      }
    };

    ViewPort.prototype.moveCursorToData = function(dataX, dataY) {
      if (dataX < 0) dataX = 0;
      if (dataX >= this.buffer.getLineCount()) {
        dataX = this.buffer.getLineCount() - 1;
      }
      if (dataY < 0) dataY = 0;
      if (dataY > this.buffer.getLine(dataX).length) {
        dataY = this.buffer.getLine(dataX).length;
      }
      if (this.dataPosition[dataX][dataY] === void 0) {
        return console.warn("Data Position fail " + dataX + " " + dataY);
      } else {
        return this.moveCursorTo(dataX, this.dataPosition[dataX][dataY]);
      }
    };

    ViewPort.prototype.moveCursorTo = function(cursorX, cursorY) {
      var oldStartX, oldStartY;
      this.cursorX = cursorX;
      this.cursorY = cursorY;
      this.removeCursor();
      if (this.cursorX < 0) this.cursorX = 0;
      if (this.cursorY < 0) this.cursorY = 0;
      oldStartX = this.startX;
      oldStartY = this.startY;
      if (this.cursorX < this.startX) this.startX = this.cursorX;
      if (this.cursorX >= this.startX + this.rows) {
        this.startX = this.cursorX - this.rows + 1;
      }
      while (this.cursorY < this.startY) {
        this.startY -= (this.columns - this.columns % 2) / 2;
      }
      if (this.startY < 0) this.startY = 0;
      while (this.cursorY >= this.startY + this.columns) {
        this.startY += (this.columns - this.columns % 2) / 2;
      }
      if (this.startX !== oldStartX || this.startY !== oldStartY) {
        this.redraw();
        console.log("Start-urile", this.startX, this.startY);
      }
      return this.elem.find(this.constructCharId(this.cursorX - this.startX, this.cursorY - this.startY)).addClass('cursor');
    };

    ViewPort.prototype.handleKeyPress = function(evt) {
      var char, now;
      if (evt.keyCode === 17 || evt.keyCode === 18 || evt.keyCode === 16 || evt.keyCode === 91) {
        return;
      }
      char = new Character(evt);
      now = new Date();
      if (now - this.lastKeyPress > 1000) this.currentKeySequence = "";
      this.lastKeyPress = now;
      this.currentKeySequence += char.symbol;
      console.log(this.currentKeySequence);
      if (this.modes[this.currentMode].hasMap(this.currentKeySequence)) {
        this.functionDatabase.callFunction(this.modes[this.currentMode].getMap(this.currentKeySequence));
        this.currentKeySequence = "";
        return true;
      }
      if (char.symbol === '<ESC>') return this.currentKeySequence = "";
    };

    ViewPort.prototype.reset = function() {
      this.startX = 0;
      this.startY = 0;
      this.cursorX = 0;
      this.cursorY = 0;
      this.elem.find("span.char").html("&nbsp;");
      return this.dataPosition = [];
    };

    ViewPort.prototype.handleLineChange = function(x, y) {
      var line, _results;
      _results = [];
      for (line = x; x <= y ? line <= y : line >= y; x <= y ? line++ : line--) {
        _results.push(this.updateLine(line));
      }
      return _results;
    };

    ViewPort.prototype.updateLine = function(dataLine) {
      var column, data, len, line, position, _ref;
      if (dataLine < this.startX || dataLine >= this.startX + this.rows) {
        return;
      } else {
        line = dataLine - this.startX;
      }
      this.elem.find(this.constructLineId(line)).find('span').html('&nbsp');
      data = this.buffer.getLine(dataLine);
      len = data.length;
      if (this.dataPosition[dataLine] === void 0) this.dataPosition[dataLine] = [];
      position = 0;
      for (column = 0, _ref = len - 1; 0 <= _ref ? column <= _ref : column >= _ref; 0 <= _ref ? column++ : column--) {
        this.dataPosition[dataLine][column] = position;
        position += this.charRenderer.render(data[column], line, position, line, column);
      }
      this.dataPosition[dataLine][column] = position;
      return this.charRenderer.render(' ', line, position, line, column);
    };

    return ViewPort;

  })();

  window.WebVim.ViewPort = ViewPort;

  /*
    This module containts the buffer related classes
  */

  Buffer = (function() {

    /*
        The main role of a buffer is to store and alter the text from a given source.
    */

    function Buffer(data) {
      /*
            data - The initial text with which the buffer is initialized
      */      this.viewPorts = {};
      this.data = [""];
      this.history = new window.WebVim.History.History(this);
    }

    Buffer.prototype.parseData = function(data) {
      /*
            This functions parses a raw string and loads it as the text of the buffer.
      
            data - The string to be parsed
      */
      var id, viewPort, _ref, _results;
      this.data = data.split("\n");
      data = this.data;
      _ref = this.viewPorts;
      _results = [];
      for (id in _ref) {
        viewPort = _ref[id];
        _results.push(setTimeout(function() {
          viewPort.reset();
          return viewPort.handleLineChange(0, data.length - 1);
        }, 0));
      }
      return _results;
    };

    Buffer.prototype.open = function(data) {
      /*
            This function should load the buffer from a given source.
            Currently it only loads data from a string.
      */      return this.parseData(data);
    };

    Buffer.prototype.addViewPort = function(viewPort) {
      /*
            Adds a viewPort to the list of viewPorts that will be notified when the buffer's data is changed
      */      return this.viewPorts[viewPort.id] = viewPort;
    };

    Buffer.prototype.deleteViewPort = function(viewPort) {
      /*
            Deletes a viewPort to the list of viewPorts that will be notified when the buffer's data is changed
      */      return delete this.viewPorts[viewPort.id];
    };

    Buffer.prototype.propagateLineChange = function(x, y) {
      var id, viewPort, _ref, _results;
      if (y == null) y = void 0;
      /*
            This function announces the viewPorts of the lines that have changed.
      */
      if (!y) y = x;
      _ref = this.viewPorts;
      _results = [];
      for (id in _ref) {
        viewPort = _ref[id];
        _results.push(viewPort.handleLineChange(x, y));
      }
      return _results;
    };

    Buffer.prototype.deleteLines = function(x, y) {
      var commit, diff, length, _ref;
      if (y == null) y = void 0;
      /*
            Deletes the lines from x to y from the text
            If y is not specified it will default to x
      */
      if (!(x > 0)) x = 0;
      if (!y) y = x;
      commit = new window.WebVim.History.Commit(this);
      commit.addDeleteOperation(x, y);
      diff = y - x + 1;
      length = this.data.length;
      [].splice.apply(this.data, [x, 9e9].concat(_ref = this.data.slice(y + 1))), _ref;
      this.history.addCommit(commit);
      return this.propagateLineChange(x, length - 1);
    };

    Buffer.prototype.insertLines = function(x, values) {
      /*
            Inserts lines of text starting on the line x
            values can be a string (if only one line is to be inserted) or an array of strings
      */
      var commit;
      commit = new window.WebVim.History.Commit(this);
      commit.addInsertOperation(x, values);
      if (typeof values === "string") values = [values];
      if (x === 0) {
        this.data = values.concat(this.data);
      } else {
        this.data = this.data.slice(0, (x - 1) + 1 || 9e9).concat(values).concat(this.data.slice(x));
      }
      this.history.addCommit(commit);
      return this.propagateLineChange(x, this.data.length - 1);
    };

    Buffer.prototype["delete"] = function(startX, startY, endX, endY) {
      /*
            Deletes texts from line startX column startY to line endX and column endY
      */
      var beginning, commit, ending;
      commit = new window.WebVim.History.Commit(this);
      commit.addDeleteOperation(startX, startX);
      if (startY === 0) {
        beginning = "";
      } else {
        beginning = this.data[startX].slice(0, (startY - 1) + 1 || 9e9);
      }
      if (endX !== startX) {
        ending = "";
      } else {
        ending = this.data[startX].slice(endY + 1);
      }
      commit.addInsertOperation(startX, beginning + ending);
      if (endX - startX >= 2) commit.addDeleteOperation(startX + 1, endX - 1);
      if (endX !== startX) {
        commit.addInsertOperation(endX, endX);
        if (endY <= this.data[endX].length - 1) {
          commit.addInsertOperation(endX, this.data[endX].slice(endY + 1));
        }
      }
      this.history.addCommit(commit);
      this.history.stopRecording();
      commit.up();
      return this.history.startRecording();
    };

    Buffer.prototype.insert = function(x, y, value) {
      /*
            Inserts text starting from line x column y
            
            value - should be a string containing the text to be inserted
      */
      var beginning, commit, ending, transport, values;
      commit = new window.WebVim.History.Commit(this);
      if (value === "") return;
      values = value.split("\n");
      commit.addDeleteOperation(x, x);
      if (y === 0) {
        beginning = "";
      } else {
        beginning = this.data[x].slice(0, (y - 1) + 1 || 9e9);
      }
      if (values.length === 1) {
        ending = this.data[x].slice(y);
        transport = "";
      } else {
        ending = "";
        transport = this.data[x].slice(y);
      }
      commit.addInsertOperation(x, beginning + values[0] + ending);
      if (values.length > 2) {
        commit.addInsertOperation(x + 1, values.slice(1, (values.length - 2) + 1 || 9e9));
      }
      if (values.length >= 2) {
        commit.addInsertOperation(x + values.length - 1, values[values.length - 1] + transport);
      }
      this.history.addCommit(commit);
      this.history.stopRecording();
      commit.up();
      return this.history.startRecording();
    };

    Buffer.prototype.getLine = function(x) {
      /*
            Returns the line x as a string
      */      if (x >= this.data.length) {
        return "";
      } else {
        return this.data[x];
      }
    };

    Buffer.prototype.getLineCount = function() {
      /*
            Returns the number of lines.
      */      return this.data.length;
    };

    Buffer.prototype.mergeLines = function(x1, x2) {
      /*
            Merges the lines from x1 to x2 into a single line
      */
      var commit, end, previous_length;
      end = Math.min(x2, this.data.length);
      if (x1 >= this.data.length) return true;
      commit = new window.WebVim.History.Commit(this);
      commit.addDeleteOperation(x1, x2);
      commit.addInsertOperation(x1, this.data.slice(x1, x2 + 1 || 9e9).join(''));
      previous_length = this.data.length;
      this.history.addCommit(commit);
      this.history.stopRecording();
      commit.up();
      this.history.startRecording();
      return this.propagateLineChange(x1, previous_length);
    };

    return Buffer;

  })();

  window.WebVim.Buffer = Buffer;

  BaseFunctionDataBase = (function() {

    function BaseFunctionDataBase(viewPort) {
      this.viewPort = viewPort;
    }

    BaseFunctionDataBase.prototype.hasFunction = function(fncName) {
      if (this.__proto__[fncName] != null) {
        return true;
      } else {
        return false;
      }
    };

    BaseFunctionDataBase.prototype.callFunction = function(name) {
      var splited_args;
      if (typeof name === "function") name(this.viewport);
      splited_args = name.split(" ");
      name = splited_args[0];
      splited_args[0] = this.viewPort;
      return this[name].apply(this, splited_args);
    };

    BaseFunctionDataBase.prototype.addFunction = function(name, fnc) {
      return this.__proto__[name] = fnc;
    };

    BaseFunctionDataBase.prototype.addFunctionDataBase = function(functionDB) {
      return this.__proto__ = merge(functionDB.__proto__, this.__proto__);
    };

    return BaseFunctionDataBase;

  })();

  MovementFunctionDatabase = (function() {

    __extends(MovementFunctionDatabase, BaseFunctionDataBase);

    function MovementFunctionDatabase() {
      MovementFunctionDatabase.__super__.constructor.apply(this, arguments);
    }

    MovementFunctionDatabase.prototype._move = function(viewport, dirX, dirY) {
      var dataX, dataY;
      dataX = viewport.getCursorDataX();
      dataY = viewport.getCursorDataY();
      dataX += dirX;
      dataY += dirY;
      return viewport.moveCursorToData(dataX, dataY);
    };

    MovementFunctionDatabase.prototype.moveLeft = function(viewport) {
      return this._move(viewport, 0, -1);
    };

    MovementFunctionDatabase.prototype.moveRight = function(viewport) {
      return this._move(viewport, 0, 1);
    };

    MovementFunctionDatabase.prototype.moveUp = function(viewport) {
      return this._move(viewport, -1, 0);
    };

    MovementFunctionDatabase.prototype.moveDown = function(viewport) {
      return this._move(viewport, 1, 0);
    };

    MovementFunctionDatabase.prototype.moveToHome = function(viewPort) {
      return viewPort.moveCursorToData(0, 0);
    };

    return MovementFunctionDatabase;

  })();

  GlobalFunctionDatabase = (function() {

    __extends(GlobalFunctionDatabase, BaseFunctionDataBase);

    function GlobalFunctionDatabase() {
      GlobalFunctionDatabase.__super__.constructor.apply(this, arguments);
    }

    GlobalFunctionDatabase.prototype.changeMode = function(viewPort, mode) {
      return viewPort.changeMode(mode);
    };

    return GlobalFunctionDatabase;

  })();

  HistoryFunctionDatabase = (function() {

    __extends(HistoryFunctionDatabase, BaseFunctionDataBase);

    function HistoryFunctionDatabase() {
      HistoryFunctionDatabase.__super__.constructor.apply(this, arguments);
    }

    HistoryFunctionDatabase.prototype.undo = function(viewPort) {
      return viewPort.buffer.history.undo();
    };

    HistoryFunctionDatabase.prototype.redo = function(viewPort) {
      return viewPort.buffer.history.redo();
    };

    return HistoryFunctionDatabase;

  })();

  InsertFunctionDatabase = (function() {

    __extends(InsertFunctionDatabase, BaseFunctionDataBase);

    function InsertFunctionDatabase() {
      InsertFunctionDatabase.__super__.constructor.apply(this, arguments);
    }

    InsertFunctionDatabase.prototype.insert = function(viewPort, letter) {
      var dataX, dataY;
      dataX = viewPort.getCursorDataX();
      dataY = viewPort.getCursorDataY();
      viewPort.buffer.insert(dataX, dataY, letter);
      if (letter === "\n") {
        return viewPort.moveCursorToData(dataX + 1, 0);
      } else {
        return viewPort.moveCursorToData(dataX, dataY + 1);
      }
    };

    InsertFunctionDatabase.prototype.insertSpace = function(viewPort) {
      return this.insert(viewPort, ' ');
    };

    InsertFunctionDatabase.prototype.deleteChar = function(viewPort) {
      var dataX, dataY, lineLength;
      dataX = viewPort.getCursorDataX();
      dataY = viewPort.getCursorDataY();
      if (dataY === 0) {
        if (dataX === 0) return true;
        lineLength = viewPort.buffer.getLine(dataX).length;
        viewPort.buffer.mergeLines(dataX - 1, dataX);
        viewPort.moveCursorToData(dataX - 1, viewPort.buffer.getLine(dataX - 1).length - lineLength);
        return true;
      }
      viewPort.buffer["delete"](dataX, dataY - 1, dataX, dataY - 1);
      return viewPort.moveCursorToData(dataX, dataY - 1);
    };

    return InsertFunctionDatabase;

  })();

  FunctionDataBase = (function() {

    __extends(FunctionDataBase, BaseFunctionDataBase);

    function FunctionDataBase(viewport) {
      FunctionDataBase.__super__.constructor.call(this, viewport);
      this.addFunctionDataBase(new MovementFunctionDatabase());
      this.addFunctionDataBase(new GlobalFunctionDatabase());
      this.addFunctionDataBase(new InsertFunctionDatabase());
      this.addFunctionDataBase(new HistoryFunctionDatabase());
    }

    FunctionDataBase.prototype.test = function() {
      return alert("merge");
    };

    return FunctionDataBase;

  })();

  Commander = (function() {

    function Commander(currentViewPortId) {
      this.currentViewPortId = currentViewPortId != null ? currentViewPortId : void 0;
      this.handleDocumentClick = __bind(this.handleDocumentClick, this);
      this.handleDocumentKeyPress = __bind(this.handleDocumentKeyPress, this);
      this.viewPorts = {};
      this.viewPortCount = 0;
      $(document).click(this.handleDocumentClick);
      $(document).keydown(this.handleDocumentKeyPress);
    }

    Commander.prototype.handleDocumentKeyPress = function(evt) {
      evt.stopPropagation();
      evt.preventDefault();
      if (this.currentViewPortId) {
        return this.viewPorts[this.currentViewPortId].handleKeyPress(evt);
      }
    };

    Commander.prototype.handleDocumentClick = function(evt) {
      var viewPortId, vim;
      if ($(evt.target).hasClass('.vim')) {
        viewPortId = $(evt.target).attr('id');
        this.changeViewPortById(viewPortId);
        return true;
      }
      vim = $(evt.target).parents('.vim');
      if (vim.length) {
        viewPortId = vim.attr('id');
        this.changeViewPortById(viewPortId);
        return true;
      }
      this.viewPorts[this.currentViewPortId].deselect();
      return this.currentViewPortId = void 0;
    };

    Commander.prototype.changeViewPortById = function(id) {
      if (this.currentViewPortId) {
        this.viewPorts[this.currentViewPortId].deselect();
      }
      this.currentViewPortId = id;
      return this.viewPorts[this.currentViewPortId].select();
    };

    Commander.prototype.register = function(viewPort) {
      var id;
      id = ++this.viewPortCount;
      id = "vim-viewport-" + id;
      this.viewPorts[id] = viewPort;
      return id;
    };

    return Commander;

  })();

  window.WebVim.commander = new Commander();

  Character = (function() {

    function Character(evt) {
      this.symbol = this.convertToSymbol(evt.keyCode, evt.shiftKey);
      this.specialKeys = [];
      this.shift(evt.shiftKey);
      this.alt(evt.altKey);
      this.ctrl(evt.ctrlKey);
    }

    Character.prototype.convertToSymbol = function(keyCode, shift) {
      var generalConvertions, keyString;
      generalConvertions = {
        '8,0': '<BS>',
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
        '186,1': ':'
      };
      console.log(keyCode);
      shift = shift ? 1 : 0;
      if (keyCode <= 90 && keyCode >= 65) {
        if (!shift) return String.fromCharCode(keyCode + 32);
        return String.fromCharCode(keyCode);
      }
      keyString = [keyCode, shift].join(',');
      if (generalConvertions[keyString] != null) {
        return generalConvertions[keyString];
      }
      return String.fromCharCode(keyCode);
    };

    Character.prototype.shift = function(value) {
      if (value == null) value = void 0;
      if (value != null) {
        return this.specialKeys[0] = value;
      } else {
        return this.specialKeys[0];
      }
    };

    Character.prototype.alt = function(value) {
      if (value == null) value = void 0;
      if (value != null) {
        return this.specialKeys[0] = value;
      } else {
        return this.specialKeys[0];
      }
    };

    Character.prototype.ctrl = function(value) {
      if (value == null) value = void 0;
      if (value != null) {
        return this.specialKeys[0] = value;
      } else {
        return this.specialKeys[0];
      }
    };

    return Character;

  })();

  KeyMapper = (function() {

    function KeyMapper() {
      this.maps = {};
    }

    KeyMapper.prototype.addKeyMapper = function(keyMapper) {
      return this.maps = merge(keyMapper.maps, this.maps);
    };

    KeyMapper.prototype.setMap = function(key, fnc) {
      return this.maps[key] = fnc;
    };

    KeyMapper.prototype.getMap = function(key) {
      return this.maps[key];
    };

    KeyMapper.prototype.hasMap = function(key) {
      if (this.maps[key] != null) {
        return true;
      } else {
        return false;
      }
    };

    KeyMapper.prototype.deleteMap = function(key) {
      return delete this.maps[key];
    };

    return KeyMapper;

  })();

  LetterMovementKeyMapper = (function() {

    __extends(LetterMovementKeyMapper, KeyMapper);

    function LetterMovementKeyMapper() {
      LetterMovementKeyMapper.__super__.constructor.call(this);
      this.setMap("h", "moveLeft");
      this.setMap("j", "moveDown");
      this.setMap("k", "moveUp");
      this.setMap("l", "moveRight");
    }

    return LetterMovementKeyMapper;

  })();

  ArrowMovementKeyMapper = (function() {

    __extends(ArrowMovementKeyMapper, KeyMapper);

    function ArrowMovementKeyMapper() {
      ArrowMovementKeyMapper.__super__.constructor.call(this);
      this.setMap("<UpArrow>", "moveUp");
      this.setMap("<DownArrow>", "moveDown");
      this.setMap("<LeftArrow>", "moveLeft");
      this.setMap("<RightArrow>", "moveRight");
      this.setMap("<Home>", "moveToHome");
    }

    return ArrowMovementKeyMapper;

  })();

  MovementKeyMapper = (function() {

    __extends(MovementKeyMapper, KeyMapper);

    function MovementKeyMapper() {
      MovementKeyMapper.__super__.constructor.call(this);
      this.addKeyMapper(new LetterMovementKeyMapper());
      this.addKeyMapper(new ArrowMovementKeyMapper());
    }

    return MovementKeyMapper;

  })();

  CommandKeyMapper = (function() {

    __extends(CommandKeyMapper, KeyMapper);

    function CommandKeyMapper() {
      CommandKeyMapper.__super__.constructor.call(this);
      this.addKeyMapper(new MovementKeyMapper());
      this.setMap("a", "changeMode Insert");
      this.setMap("u", "undo");
      this.setMap("C^u", "redo");
    }

    return CommandKeyMapper;

  })();

  InsertKeyMapper = (function() {

    __extends(InsertKeyMapper, KeyMapper);

    function InsertKeyMapper() {
      InsertKeyMapper.__super__.constructor.call(this);
      this.setMap("<ESC>", "changeMode Command");
      this.setMap("<CR>", "insert \n");
      this.setMap("<BS>", "deleteChar");
      this.setMap(" ", "insertSpace");
      this.addKeyMapper(new ArrowMovementKeyMapper());
    }

    InsertKeyMapper.prototype.hasMap = function(key) {
      return true;
    };

    InsertKeyMapper.prototype.getMap = function(key) {
      if (this.maps[key] != null) {
        return InsertKeyMapper.__super__.getMap.call(this, key);
      }
      return "insert " + key;
    };

    return InsertKeyMapper;

  })();

  window.WebVim.History = {};

  Commit = (function() {

    function Commit(buffer) {
      this.buffer = buffer;
      this.operations = [];
    }

    Commit.prototype.addOperation = function(operation) {
      return this.operations.push(operation);
    };

    Commit.prototype.addInsertOperation = function(x, values) {
      var length;
      if (typeof values === "string") {
        length = 1;
      } else {
        length = values.length;
      }
      return this.addOperation({
        upFunction: "insertLines",
        upData: [x, values],
        downFunction: "deleteLines",
        downData: [x, x + length - 1]
      });
    };

    Commit.prototype.addDeleteOperation = function(x, y) {
      return this.addOperation({
        upFunction: "deleteLines",
        upData: [x, y],
        downFunction: "insertLines",
        downData: [x, this.buffer.data.slice(x, y + 1 || 9e9)]
      });
    };

    Commit.prototype.up = function() {
      var op, _i, _len, _ref, _results;
      _ref = this.operations;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        op = _ref[_i];
        _results.push(this.buffer[op.upFunction].apply(this.buffer, op.upData));
      }
      return _results;
    };

    Commit.prototype.down = function() {
      for (var i = this.operations.length - 1; i>=0 ; i--){
       var op = this.operations[i];
       this.buffer[op.downFunction].apply(this.buffer, op.downData);
    };      return true;
    };

    return Commit;

  })();

  window.WebVim.History.Commit = Commit;

  History = (function() {

    function History(buffer) {
      this.buffer = buffer;
      this.commits = [];
      this.currentCommit = void 0;
      this.undoneCommits = [];
      this.extendRecording = 0;
      this.isRecording = 0;
    }

    History.prototype.stopRecording = function() {
      return this.isRecording--;
    };

    History.prototype.startRecording = function() {
      if (this.isRecording !== 0) return this.isRecording++;
    };

    History.prototype.addCommit = function(commit) {
      if (this.isRecording === 0) {
        this.commits.push(commit);
        this.currentCommit = commit;
        return this.undoneCommits = [];
      }
    };

    History.prototype.undo = function(count) {
      var commit;
      if (count == null) count = 1;
      this.stopRecording();
      while (count && this.commits.length) {
        commit = this.commits.pop();
        this.undoneCommits.push(commit);
        this.currentCommit = this.commits[this.commits.length - 1];
        commit.down();
        count--;
      }
      return this.startRecording();
    };

    History.prototype.redo = function(count) {
      var commit;
      if (count == null) count = 1;
      this.stopRecording();
      while (count && this.undoneCommits.length) {
        commit = this.undoneCommits.pop();
        this.commits.push(commit);
        this.currentCommit = this.commits[this.commits.length - 1];
        commit.up();
        count--;
      }
      return this.startRecording();
    };

    return History;

  })();

  window.WebVim.History.History = History;

}).call(this);
