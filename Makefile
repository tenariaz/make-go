APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/tenariaz
GIT_TAG=$(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
VERSION=$(GIT_TAG)-$(shell git rev-parse --short HEAD)
TARGETOS ?= $(shell go env GOOS)
TARGETARCH ?= $(shell go env GOARCH)
IMAGE_TAG=$(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

PLATFORMS = linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64

.PHONY: format lint test get build image push clean \
        linux linux-arm macos macos-arm windows \
        image-linux image-linux-arm image-macos image-macos-arm image-windows

format:
	go fmt ./...

lint:
	golangci-lint run

test:
	go test ./...

get:
	go mod tidy

build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot$(if $(filter windows,$(TARGETOS)),.exe,) -ldflags "-X=github.com/tenariaz/kbot/cmd.appVersion=$(VERSION)"

linux:
	$(MAKE) build TARGETOS=linux TARGETARCH=amd64

linux-arm:
	$(MAKE) build TARGETOS=linux TARGETARCH=arm64

macos:
	$(MAKE) build TARGETOS=darwin TARGETARCH=amd64

macos-arm:
	$(MAKE) build TARGETOS=darwin TARGETARCH=arm64

windows:
	$(MAKE) build TARGETOS=windows TARGETARCH=amd64

image:
	docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE_TAG) \
		--load .

image-linux:
	$(MAKE) image TARGETOS=linux TARGETARCH=amd64

image-linux-arm:
	$(MAKE) image TARGETOS=linux TARGETARCH=arm64

image-macos:
	$(MAKE) image TARGETOS=darwin TARGETARCH=amd64

image-macos-arm:
	$(MAKE) image TARGETOS=darwin TARGETARCH=arm64

image-windows:
	$(MAKE) image TARGETOS=windows TARGETARCH=amd64

push:
	docker push $(IMAGE_TAG)

clean:
	rm -f kbot kbot.exe
	-docker rmi $(IMAGE_TAG) 2>/dev/null || true
