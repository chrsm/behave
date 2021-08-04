.PHONY: all build test list

LPATH = "./?.lua;./?/?.lua;./?/init.lua"

test: build
	busted -m $(LPATH) -v ./behave

list: build
	busted -m $(LPATH) -l ./behave

build:
	yue ./behave

release: build test
	mkdir -p ./build/behave
	cp behave/*.lua build/behave
	cd build && tar cvfz behave-build.tar.gz behave
	ls -lha build/behave-build.tar.gz
