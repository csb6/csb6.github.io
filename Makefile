OPTIONS=--css=index.css --include-before-body=_header.pandoc --include-after-body=_footer.pandoc

site: index.html projects.html

index.html: _index.md _header.pandoc _footer.pandoc
	pandoc $(OPTIONS) -M pagetitle="Cole Blakley - Home" -o index.html _index.md

projects.html: _projects.md _header.pandoc _footer.pandoc
	pandoc $(OPTIONS) -M pagetitle="Cole Blakley - Projects" -o projects.html _projects.md

clean:
	rm -rf *.html *~
