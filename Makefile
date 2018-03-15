VERSION ?= $(shell git describe --exact-match --abbrev=0 --tags 2>/dev/null)
REVISION := $(shell git rev-parse --short HEAD)

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
BINDIR = build/$(GOOS)/$(GOARCH)

LDFLAGS := -s -w
ifneq ($(VERSION),)
	LDFLAGS += -X main.version=$(VERSION)
endif
LDFLAGS += -X main.gitcommit=$(REVISION)

TARGET := $(BINDIR)/mackerel-plugin-mellanox-infiniband

all: lint build

build: deps
	$(MAKE) $(TARGET)

.SECONDEXPANSION:
$(TARGET): main.go
	@if [ ! -d $(BINDIR) ]; then mkdir -p $(BINDIR); fi
	go build -ldflags "$(LDFLAGS)" -o $(TARGET)

deps:
	go get -d -v

lint: testdeps
	go vet
	golint -set_exit_status

testdeps:
	go get -d -v -t
	go get github.com/golang/lint/golint

clean:
	@if [ -d build ]; then rm -rfv build; fi

.PHONY: all build deps lint testdeps clean
