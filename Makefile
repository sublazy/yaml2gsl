CFLAGS = -std=c99 -g

LINK_LIBS = -lyaml

all: main

main: yaml2gsl.c build-dir
	@cc $(CFLAGS) yaml2gsl.c $(LINK_LIBS) -o out/yaml2gsl

deconstructor: example-deconstructor.c build-dir
	@cc $(CFLAGS) example-deconstructor.c $(LINK_LIBS) -o out/deconstructor

build-dir:
	@mkdir -p out

clean:
	@rm -rf out

.PHONY: all clean main
