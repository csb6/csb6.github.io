OPTIONS=--css=index.css --include-before-body=header.pandoc --include-after-body=footer.pandoc

site: index.html projects.html

index.html: index.md header.pandoc footer.pandoc
	pandoc $(OPTIONS) -M pagetitle="Cole Blakley - Home" -o index.html index.md

projects.html: projects.md header.pandoc footer.pandoc
	pandoc $(OPTIONS) -M pagetitle="Cole Blakley - Projects" -o projects.html projects.md

clean:
	rm -rf *.html *~
