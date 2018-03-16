VERSION ?= $(shell git describe --exact-match --abbrev=0 --tags 2>/dev/null)
REVISION := $(shell git rev-parse --short HEAD)

GOOS := linux
GOARCH := amd64
BINDIR := build/$(GOOS)/$(GOARCH)

LDFLAGS := -s -w
ifneq ($(VERSION),)
	LDFLAGS += -X main.version=$(VERSION)
endif
LDFLAGS += -X main.gitcommit=$(REVISION)

TARGET := mackerel-plugin-mellanox-infiniband

all: lint build

build: deps
	$(MAKE) $(BINDIR)/$(TARGET)

.SECONDEXPANSION:
$(BINDIR)/$(TARGET): main.go
	@if [ ! -d $(BINDIR) ]; then mkdir -p $(BINDIR); fi
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -ldflags "$(LDFLAGS)" -o $(BINDIR)/$(TARGET)

deps:
	go get -d -v

lint: testdeps
	go vet
	golint -set_exit_status

testdeps:
	go get -d -v -t
	go get github.com/golang/lint/golint

clean:
	@if [ -d dist ]; then rm -rfv dist; fi
	@if [ -d build ]; then rm -rfv build; fi

release: dist/$(VERSION)/$(TARGET)_$(GOOS)_$(GOARCH).zip
	hub release create -d -a "dist/$(VERSION)/$(TARGET)_$(GOOS)_$(GOARCH).zip" -m "$(VERSION)" "$(VERSION)"

dist/$(VERSION)/$(TARGET)_$(GOOS)_$(GOARCH).zip: clean build
	./release.sh

.PHONY: all build deps lint testdeps clean release
