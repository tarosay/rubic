
COFFEE    := $(shell which coffee 2>/dev/null)
JSDUCKIFY := $(shell which jsduckify 2>/dev/null)
UGLIFYJS  := $(shell which uglifyjs 2>/dev/null)

Q ?= @
TARGET = app.js lib.js
RELEASE = $(TARGET:.js=.min.js)
RUNNER = node
DOCDIR = docs
SOURCES = \
	async.coffee \
	base.coffee \
	port.coffee \
		serialport.coffee \
	memhttprequest.coffee \
	board.coffee \
		peridotboard.coffee \
		wakayamarbboard.coffee \
	editor.coffee \
		rubyeditor.coffee \
		yamleditor.coffee \
	fileutil.coffee \
	builder.coffee \
		mrubybuilder.coffee \
	sketch.coffee \
	filesystem.coffee \
		localfilesystem.coffee \
		googledrivefilesystem.coffee \
#	marshal.coffee \
#	sandbox.coffee
#		de0board.coffee \
#		de0nanoboard.coffee \

LIB_SOURCES = \
	mruby/build/emscripten/bin/mrbc.js

.PHONY: all
all: $(TARGET)

.PHONY: run
run: all
	@echo "[Running]"
	$(Q)$(RUNNER) $(RELEASE) $(LIB)

.PHONY: release
release: $(RELEASE)

.PHONY: clean
clean:
	@echo "[Cleaning]"
	$(Q)rm -f $(TARGET) $(RELEASE)

%.min.js: %.js $(firstword $(UGLIFYJS) uglifyjs-is-missing)
	@echo "[Minimizing $<]"
	$(Q)$(UGLIFYJS) -o $@ $< || (rm -f $@; false)

%.js: %.coffee $(firstword $(COFFEE) coffee-is-missing) $(MAKEFILE_LIST)
	@echo "[Compiling CoffeeScript files]"
	$(Q)coffee -c $< > $@ || (rm -f $@; false)

app.coffee: $(SOURCES) $(MAKEFILE_LIST)
	$(Q)cat /dev/null $(filter %.coffee,$^) > $@ || (rm -f $@; false)

lib.js: $(LIB_SOURCES) $(MAKEFILE_LIST)
	@echo "[Importing external libraries]"
	$(Q)echo "var Lib;Lib=(function(){function Lib(){}" > $@.tmp
	$(Q)true $(foreach f,$(filter %.js,$^), \
		&& echo "\
		Lib.$(notdir $(basename $(f)))=function(Module){\
		Module['preInit'] = Module['preInit'] || [];\
		Module['preInit'].unshift(function(){\
		  Module['exports'] = {FS: FS, MEMFS: MEMFS};\
		});" >> $@.tmp \
		&& cat $(f) >> $@.tmp \
		&& echo "};" >> $@.tmp)
	$(Q)echo "return Lib;})();" >> $@.tmp
	$(Q)mv $@.tmp $@
#		&& echo "Module.exports={};" >> $@.tmp \
#		&& echo "Module.exports.fs=FS;" >> $@.tmp \

.PHONY: doc
doc: $(TARGET) $(firstword $(JSDUCKIFY) jsduckify-is-missing)
	@echo "[Generating document]"
	$(Q)$(JSDUCKIFY)

.PHONY: uglifyjs-is-missing
uglifyjs-is-missing:
	@echo "**** UglifyJS is required to build this project."
	@echo "**** Please visit https://github.com/mishoo/UglifyJS"
	@false

.PHONY: coffee-is-missing
coffee-is-missing:
	@echo "**** CoffeeScript is required to build this project."
	@echo "**** Please visit http://coffeescript.org/"
	@false

.PHONY: jsduckify-is-missing
jsduckify-is-missing:
	@echo "**** jsduckify is required to generate document for this project."
	@echo "**** Please visit https://github.com/lmaccherone/jsduckify"
	@false

.PHONY: dist
dist: $(TARGET) background.js manifest.json \
	ace-builds/src-noconflict/ace.js ace-builds/src-noconflict/mode-ruby.js \
	bootbox/bootbox.js \
	bootstrap-notify/dist/bootstrap-notify.min.js \
	bootstrap/dist/css/bootstrap.min.css bootstrap/dist/js/bootstrap.min.js \
	bootstrap/dist/fonts/glyphicons-halflings-regular.woff \
	js-yaml/dist/js-yaml.min.js \
	canarium.js \
	jquery-2.1.1.min.js \
	jquery.spin.js \
	spin.min.js \
	window.css window.html
	@echo "[Packing distribution files]"
	$(Q)mkdir -p ../dist
	$(Q)cp --parent $^ ../dist
	$(Q)rm -f ../rubic.zip
	$(Q)cd .. && zip -r rubic.zip dist

