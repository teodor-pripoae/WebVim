JS = js/webvim.js js/templates/webvim.js
CSS= css/webvim.css

build: $(JS) $(CSS)
	
%.js : %.coffee
	coffee -c $^

%.js : %.soy
	java -jar SoyToJsSrcCompiler.jar --outputPathFormat $@ $^

%.css: %.sass
	sass $^:$@
