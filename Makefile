APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/tenariaz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= linux
TARGETARCH ?= amd64
IMAGE_TAG=$(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X=github.com/tenariaz/kbot/cmd.appVersion=$(VERSION)"

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
	mv kbot kbot.exe

image:
	docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--tag $(IMAGE_TAG) \
		--output=type=docker .

# Alias-цілі для зручності
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
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean:
#	rm -rf kbot kbot.exe
	@docker rmi $(shell docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^$(REGISTRY)/$(APP):$(VERSION)") 2>/dev/null || true
