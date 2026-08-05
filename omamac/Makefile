# omamac — Omakub for macOS
.PHONY: all build install test lint vet fmt shellcheck check unit integration dryrun clean

BINARY      := omamac
VERSION     ?= dev
LDFLAGS     := -s -w -X github.com/irfancode/omamac/internal/cli.version=$(VERSION)
GOFLAGS     ?=

all: fmt vet build

build:
	@mkdir -p bin
	go build $(GOFLAGS) -ldflags "$(LDFLAGS)" -o bin/$(BINARY) ./cmd/omamac

install: build
	@install -m 0755 bin/$(BINARY) "$${HOME}/.local/bin/$(BINARY)"
	@echo "Installed to $${HOME}/.local/bin/$(BINARY)"

test:
	go test ./... -coverprofile=coverage.out

test-race:
	go test -race ./...

unit:
	go test ./internal/...

integration:
	go test ./tests/... -tags=integration

lint:
	golangci-lint run ./...

vet:
	go vet ./...

fmt:
	gofmt -l -w .

shellcheck:
	shellcheck install.sh scripts/*.sh plugins/examples/*/*/*.sh

check: fmt vet lint shellcheck test

dryrun:
	./bin/$(BINARY) install --dry-run --yes

clean:
	rm -rf bin dist coverage.out

## Release pipeline (local preview)
snapshot:
	goreleaser release --snapshot --clean
