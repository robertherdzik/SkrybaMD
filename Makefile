PREFIX?=/usr/local

build:
	swift build -c release

clean_build:
	rm -rf .build
	make build

install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/SkrybaMD" "$(PREFIX)/bin/SkrybaMD"

get_version:
	@cat .version

