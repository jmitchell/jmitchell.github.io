REPO := $(shell git config --get remote.origin.url)
GHPAGES = master

CSSDIR = $(GHPAGES)/css
CSSFILE = $(CSSDIR)/main.css


all: init clean $(GHPAGES) $(CSSFILE) $(addprefix $(GHPAGES)/, $(addsuffix .html, $(basename $(wildcard *.md))))


$(GHPAGES)/%.html: %.md
	pandoc -s --template "_layout" -c "css/main.css" -f markdown -t html5 -o "$@" "$<"

$(CSSFILE): $(CSSDIR)

$(CSSDIR):
	mkdir -p "$(CSSDIR)"

$(GHPAGES):
	@echo $(REPO)
	git clone "$(REPO)" "$(GHPAGES)"
	(cd $(GHPAGES) && git checkout $(GHPAGES)) || (cd $(GHPAGES) && git checkout --orphan $(GHPAGES) && git rm -rf .)


init:
	@command -v pandoc > /dev/null 2>&1 || (echo 'Pandoc not found. See http://johnmacfarlane.net/pandoc/installing.html' && exit 1)

serve:
	cd $(GHPAGES) && python -m SimpleHTTPServer

commit:
	cd $(GHPAGES) && \
	    git add . && \
	    git commit --edit --message="Publish @$$(date)"
	cd $(GHPAGES) && \
	    git push origin $(GHPAGES)

clean:
	rm -rf "$(GHPAGES)"


.PHONY: init clean commit serve
