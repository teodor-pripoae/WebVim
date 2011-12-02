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
    