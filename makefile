COFFEE = js/webvim.coffee js/viewport.coffee js/buffer.coffee js/functions.coffee js/global_commander.coffee js/keymaps.coffee js/viewport.coffee js/undo.coffee
#"js/templates/webvim.js"
CSS= css/webvim.css

COFFEE_JS = js/webvim.js
SOY_JS = js/templates/webvim.js

build: $(COFFEE_JS) $(CSS) $(SOY_JS)

$(COFFEE_JS): $(COFFEE)
	coffee  --join js/webvim.js --compile $^ 

%.js : %.soy
	java -jar SoyToJsSrcCompiler.jar --outputPathFormat $@ $^

%.css: %.sass
	sass $^:$@

.PHONY: tests

tests:
	@(cd tests; make)
