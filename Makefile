SHELL := /bin/bash
PWD := $(shell pwd)

.PHONY: run test \
			debug \
			screen \
			drivers \
			zip

drivers:

zip:
	@zip -r Project.zip microsemi
	@mv Project.zip microsemi/Project.zip
	@[ -d project ] && rm -rf project

screen:
	@screen /dev/ttyUSB0 57600

test:
	@python3 main.py --mode test

debug:
	@stty -F /dev/ttyUSB0 57600
	@python3 main.py --mode debug

run:
	@python3 main.py


