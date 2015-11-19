DOMAIN := "www.requisitebits.com"
REPO := "git@github.com:jmitchell/jmitchell.github.io.git"

NPM_BIN = $(shell npm bin)
PROJ_ROOT = $(shell pwd)

PREPROC_DIR = ./preproc
PUB_DIR = ./pub
PROD_DIR = ./prod

DOC_DIR = $(PREPROC_DIR)/md
DOC_FILES = $(shell find $(DOC_DIR) -type f -name '*.md')
HTML_FILES = $(patsubst $(DOC_DIR)/%.md, $(PUB_DIR)/%.html, $(DOC_FILES))
IMG_FILES = $(patsubst $(PREPROC_DIR)/img/%, $(PUB_DIR)/img/%, $(shell find $(PREPROC_DIR)/img -type f -name '*.png' -o -name '*.svg'))
CSS_FILES = $(patsubst $(PREPROC_DIR)/css/%, $(PUB_DIR)/css/%, $(shell find $(PREPROC_DIR)/css -type f))

.PHONY: all clean watch refresh_preview diff ship

all: $(PUB_DIR)

clean:
	rm -rf $(PUB_DIR)/* $(PROD_DIR)

watch: all watcher.sh $(PREPROC_DIR) $(PUB_DIR)
	@./watcher.sh $(PREPROC_DIR) $(PUB_DIR)

refresh_preview: clean all
	@osascript refresh_chrome.scpt

diff: $(PUB_DIR) $(PROD_DIR)
	@diff -y -r "$(PROD_DIR)" "$(PUB_DIR)" | colordiff | less -R

commit:
	$(eval WORKSPACE := $(shell mktemp -d /tmp/webpub.XXXXX))
	@git clone $(REPO) $(WORKSPACE)
	cd $(WORKSPACE) && \
		git checkout master && \
		git rm -rf . && \
		cp -r $(PROJ_ROOT)/$(PUB_DIR)/* . && \
		git add . && \
		git commit --edit --message="Publish @$$(date)" && \
		git push origin master
	@rm -rf $(WORKSPACE)

$(PUB_DIR): $(HTML_FILES) $(IMG_FILES) $(CSS_FILES)
	@echo $(DOMAIN) > $(PUB_DIR)/CNAME

$(PUB_DIR)/%.html: $(DOC_DIR)/%.md
	@mkdir -p "$(@D)"
	@echo converting "$<" to "$@"
	@pandoc -s --template "$(PREPROC_DIR)/_layout" -c "/css/reset.css" -c "/css/main.css" -f markdown -t html5 -o "$@" "$<"

$(PUB_DIR)/css/%: $(PREPROC_DIR)/css/%
	@mkdir -p "$(@D)"
	@cp "$<" "$@"
	@$(NPM_BIN)/postcss -u autoprefixer -u postcss-simple-vars -u lost -c $(PREPROC_DIR)/postcss-conf.json -r "$@"

$(PUB_DIR)/img/%: $(PREPROC_DIR)/img/%
	@mkdir -p "$(@D)"
	@cp "$<" "$@"

$(PROD_DIR):
	# TODO: allow offline mode if no connectivity
	@rm -rf "$(PROD_DIR)"
	@git clone "$(REPO)" "$(PROD_DIR)"
	@cd "$(PROD_DIR)" && git checkout master && rm -rf .git
