# Notes:
#   - -M means --metadata
#   - pagetitle only sets the <title> in the <head>; title sets both the <title> and adds an <h1> to the page
OPTIONS = --standalone -M lang="en"
BLOG_HEADER = --include-before-body=_headers/header.html

.PHONY: site
site: index.html lr-spec.html purple-yt/index.html purple-yt/privacy-policy.html

index.html: _index.md _headers/header.html
	pandoc $(OPTIONS) $(BLOG_HEADER) --css=index.css -M pagetitle="Cole's Blog - Index" -o index.html _index.md

lr-spec.html: _lr-spec.md _headers/header.html
	pandoc $(OPTIONS) $(BLOG_HEADER) --css=index.css -M title="A Formal Specification of LR Parsers" -o lr-spec.html _lr-spec.md

purple-yt/index.html: purple-yt/_index.md _headers/header.html
	pandoc $(OPTIONS) --css=purple.css -M title="Purple-YT" -o purple-yt/index.html purple-yt/_index.md

purple-yt/privacy-policy.html: purple-yt/_privacy-policy.md _headers/header.html
	pandoc $(OPTIONS) --css=purple.css -M title="Purple-YT Privacy Policy" -o purple-yt/privacy-policy.html purple-yt/_privacy-policy.md

.PHONY: clean
clean:
	rm -f *.html purple-yt/*.html *~
