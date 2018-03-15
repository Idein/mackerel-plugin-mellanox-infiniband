GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
BINDIR = build/$(GOOS)/$(GOARCH)

LDFLAGS := -s -w

TARGET := $(BINDIR)/mackerel-plugin-mellanox-infiniband

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

.PHONY: build deps lint testdeps clean
