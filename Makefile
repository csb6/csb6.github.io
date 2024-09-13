# Notes:
#   - -M means --metadata
#   - pagetitle only sets the <title> in the <head>; title sets both the <title> and adds an <h1> to the page
OPTIONS = --standalone --css=index.css --include-before-body=_headers/header.html -M lang="en"

.PHONY: site
site: index.html lr-spec.html

index.html: _index.md _headers/header.html
	pandoc $(OPTIONS) -M pagetitle="Cole's Blog - Index" -o index.html _index.md

lr-spec.html: _lr-spec.md _headers/header.html
	pandoc $(OPTIONS) -M title="A Formal Specification of LR Parsers" -o lr-spec.html _lr-spec.md

.PHONY: clean
clean:
	rm -f *.html *~
