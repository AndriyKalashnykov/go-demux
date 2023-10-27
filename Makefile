CURRENTTAG:=$(shell git describe --tags --abbrev=0)
NEWTAG ?= $(shell bash -c 'read -p "Please provide a new tag (currnet tag - ${CURRENTTAG}): " newtag; echo $$newtag')
GOFLAGS=-mod=mod
OS ?= $(shell uname -s | tr A-Z a-z)

.DEFAULT_GOAL := help

#help: @ List available tasks
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo "Commands :"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-7s\033[0m - %s\n", $$1, $$2}'

#clean: @ Cleanup
clean:
	@sudo rm -rf .bin/ dist/

#build: @ Build
build: clean
	@export GOFLAGS=$(GOFLAGS); go build ./...

#test: @ Run tests
test:
	@export export GOFLAGS=$(GOFLAGS); go test ./...

#update: @ Update dependency packages to latest versions
update:
	@export GOFLAGS=$(GOFLAGS); go get -u; go mod tidy; cd ..

#get: @ Download and install dependency packages
get:
	@export GOFLAGS=$(GOFLAGS); go get ./... ; go mod tidy

#release: @ Create and push a new tag
release:
	$(eval NT=$(NEWTAG))
	@echo -n "Are you sure to create and push ${NT} tag? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo ${NT} > ./version.txt
	@git add -A
	@git commit -a -s -m "Cut ${NT} release"
	@git tag ${NT}
	@git push origin ${NT}
	@git push
	@echo "Done."

#version: @ Print current version(tag)
version:
	@echo $(shell git describe --tags --abbrev=0)
