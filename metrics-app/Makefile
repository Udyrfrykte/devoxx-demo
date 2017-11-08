.PHONY: all lint install-lint vet tests install-gvt fmt deps-get deps-update fmt

all: lint vet tests app

install-lint:
	go get github.com/golang/lint/golint

lint: install-lint
	golint -set_exit_status

vet:
	go tool vet -composites=false .

tests: cover.html

cover.out: *.go vendor/manifest
	go test -v -cover -coverprofile=$@ app

cover.html: cover.out
	go tool cover -html=$< -o $@

app: *.go vendor/manifest
	CGO_ENABLED=0 GOOS=linux go build -o $@ -ldflags "-X main.version=${CI_COMMIT_SHA} -X main.timestamp=$(shell date +%s)"
	strip $@

clean:
	rm -f app cover.out cover.html

install-gvt:
	go get github.com/FiloSottile/gvt

deps-get: install-gvt
	gvt restore

deps-update: install-gvt
	gvt update -all

fmt:
	gofmt -w -d *.go
