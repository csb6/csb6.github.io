# Notes:
#   - -M means --metadata
#   - pagetitle only sets the <title> in the <head>; title sets both the <title> and adds an <h1> to the page
OPTIONS = --standalone -M lang="en"
BLOG_HEADER = --include-before-body=_headers/header.html

.PHONY: site
site: index.html lr-spec.html birdtube/index.html birdtube/privacy-policy.html birdtube/terms.html

index.html: _index.md _headers/header.html
	pandoc $(OPTIONS) $(BLOG_HEADER) --css=index.css -M pagetitle="Cole's Blog - Index" -o index.html _index.md

lr-spec.html: _lr-spec.md _headers/header.html
	pandoc $(OPTIONS) $(BLOG_HEADER) --css=index.css -M title="A Formal Specification of LR Parsers" -o lr-spec.html _lr-spec.md

birdtube/index.html: birdtube/_index.md _headers/header.html
	pandoc $(OPTIONS) --css=purple.css -M title="BirdTube" -o birdtube/index.html birdtube/_index.md

birdtube/privacy-policy.html: birdtube/_privacy-policy.md _headers/header.html
	pandoc $(OPTIONS) --css=purple.css -M title="BirdTube Privacy Policy" -o birdtube/privacy-policy.html birdtube/_privacy-policy.md

birdtube/terms.html: birdtube/_terms.md _headers/header.html
	pandoc $(OPTIONS) --css=purple.css -M title="BirdTube Terms and Conditions" -o birdtube/terms.html birdtube/_terms.md

.PHONY: clean
clean:
	rm -f *.html birdtube/*.html *~
