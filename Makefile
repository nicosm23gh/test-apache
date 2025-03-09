all: p2.1.pdf p2.2.pdf p2.3.ssl.pdf

%.pdf: %.adoc
	docker run --rm  -v `pwd`:/documents/ docker.io/asciidoctor/docker-asciidoctor asciidoctor-pdf -r asciidoctor-diagram -a lang=es $<

%.html: %.adoc
	docker run --rm  -v `pwd`:/documents/ docker.io/asciidoctor/docker-asciidoctor asciidoctor -r asciidoctor-diagram -a lang=es $<

clean:
	rm -f *.html *.pdf *.odt *.xml
