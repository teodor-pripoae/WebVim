describe "Buffer", ()->

  describe "when parsing data", () ->
    buffer = undefined
    beforeEach ()->
      buffer = new window.WebVim.Buffer()
      
    it "should parse the text from a string by spliting it using \\n", ()->
      buffer.parseData("Ana are mere\n pere si bere")
      expect(buffer.data).toEqual ["Ana are mere"," pere si bere"]
      
    it "should not split the text when no \\n is given", ()->
      buffer.parseData("Ana are mere")
      expect(buffer.data).toEqual ["Ana are mere"]
    
    it "should split correctly when there are multiple consecutive \\n", () ->
      buffer.parseData("\n\n Ana are\nmere si \n\n pere \n\n")
      expect(buffer.data).toEqual ["",""," Ana are","mere si ",""," pere ", "", ""]


  describe "when inserting a character", () ->
    buffer = undefined
    beforeEach () ->
      buffer = new window.WebVim.Buffer()
      buffer.parseData "\nAna are mere\n"

    describe "on a line with text", () ->
      it "should correctly insert a characater somewhere in the line", ()->
        buffer.insertAt 1, 1, 'z'
        expect(buffer.data).toEqual ["","Azna are mere",""]

      it "should correctly insert a character at the beginning of a line", () ->
        buffer.insertAt 1,0,'z'
        expect(buffer.data).toEqual ["", "zAna are mere", ""]

      it "should correctly insert a character at the end", () ->
        buffer.insertAt 1,12,'z'
        expect(buffer.data).toEqual ["", "Ana are merez", ""]

      it "should add spaces if it is after the end of the line", () ->
        buffer.insertAt 1,14,'z'
        expect(buffer.data).toEqual ["", "Ana are mere  z", ""]

    describe "on an empty line", () ->
      it "should correctly insert it at the beginning of the line", () ->
        buffer.insertAt 0,0,'z'
        expect(buffer.data).toEqual ["z", "Ana are mere", ""]

      it "should add spaces if it is not inserted at the beginning of the line", () ->
        buffer.insertAt 0,1,'z'
        expect(buffer.data).toEqual [" z", "Ana are mere", ""]
        buffer.insertAt 2,3,'z'
        expect(buffer.data).toEqual [" z", "Ana are mere", "   z"]

    describe "on a line that doesn't exists", () ->
      it "should create empty lines till that line", () ->
        buffer.insertAt 3,0,'z'

        expect(buffer.data).toEqual ["", "Ana are mere", "", "z"]
        buffer.insertAt 5,0,'a'
        expect(buffer.data).toEqual ["", "Ana are mere", "", "z","", "a"]
        buffer.insertAt 9,0,'b'
        expect(buffer.data).toEqual ["", "Ana are mere", "", "z", "", "a", "", "", "", "b"]

  describe "when inserting a new line", () ->
    buffer = undefined
    beforeEach () ->
      buffer= new window.WebVim.Buffer()
      buffer.parseData "\nAna are mere\n\n"

    it "should work when inserting at the end of a line with text", () ->
      buffer.addNewLine 1, 12
      expect(buffer.data).toEqual ["", "Ana are mere", "", "", ""]


    describe "should transport characters to the new line", () ->

      it "when inserting on the last character", () ->
        buffer.addNewLine 1, 11
        expect(buffer.data).toEqual ["", "Ana are mer", "e", "", ""]

      it "when inserting somewhere in the string", () ->
        buffer.addNewLine 1, 8
        expect(buffer.data).toEqual ["", "Ana are ", "mere", "", ""]

      it "when inserting on the first character", () ->
        buffer.addNewLine 1,0
        expect(buffer.data).toEqual  ["", "", "Ana are mere", "", ""]


    it "should work when inserting on an empty line", () ->
      buffer.addNewLine 0,0
      expect(buffer.data).toEqual ["", "", "Ana are mere", "", ""]

    it "should work when inserting a line on the last line", () ->
      buffer.addNewLine 3,0
      expect(buffer.data).toEqual ["", "Ana are mere", "", "", ""]

    it "should create empty lines till the current line if it doesn't exist", ()->
      buffer.addNewLine 5,0
      expect(buffer.data).toEqual ["", "Ana are mere", "", "", "", "", ""]


  describe "when deleting a line", () ->

