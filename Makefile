PREPROC_DIR = ./preproc
PUB_DIR = ./pub

DOC_DIR = $(PREPROC_DIR)/md
DOC_FILES = $(shell find $(DOC_DIR) -type f -name '*.md')
HTML_FILES = $(patsubst $(DOC_DIR)/%.md, $(PUB_DIR)/%.html, $(DOC_FILES))
CSS_FILE = $(PUB_DIR)/css/main.css


.PHONY: all clean watch refresh_preview diff ship

all: $(PUB_DIR)

clean:
	rm -rf $(PUB_DIR)

watch: all watcher.sh
	@./watcher.sh $(PREPROC_DIR) $(PUB_DIR)

refresh_preview: all
	@echo "TODO: Refresh browser"

diff:
	@echo "TODO: diff pending deployment against production"

ship:
	@echo "TODO: Ship"


$(PUB_DIR): $(CSS_FILE) $(HTML_FILES)

$(CSS_FILE): $(PREPROC_DIR)/css/main.css
	@mkdir -p $(shell dirname $(CSS_FILE))
	@cp $(PREPROC_DIR)/css/main.css $(CSS_FILE)

$(PUB_DIR)/%.html: $(DOC_DIR)/%.md $(CSS_FILE)
	@mkdir -p "$(@D)"
	@echo converting "$<" to "$@"
	@pandoc -s --template "_layout" -c "$(CSS_FILE)" -f markdown -t html5 -o "$@" "$<"
