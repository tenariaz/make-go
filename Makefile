APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/tenariaz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS ?= linux
TARGETARCH ?= amd64
IMAGE_TAG=$(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
PLATFORMS=linux/amd64 linux/arm64 windows/amd64 darwin/amd64 darwin/arm64

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

image-only:
	docker buildx build \
		--platform $(TARGETOS)/$(TARGETARCH) \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--tag $(IMAGE_TAG) \
		--output=type=docker .
image:
	docker buildx build \
		$(foreach p,$(PLATFORMS),--platform $(p) ) \
		--build-arg VERSION=$(VERSION) \
		--tag $(REGISTRY)/$(APP):$(VERSION) \

# Alias-цілі для зручності
image-linux:
	$(MAKE) image-only TARGETOS=linux TARGETARCH=amd64

image-linux-arm:
	$(MAKE) image-only TARGETOS=linux TARGETARCH=arm64

image-macos:
	$(MAKE) image-only TARGETOS=darwin TARGETARCH=amd64

image-macos-arm:
	$(MAKE) image-only TARGETOS=darwin TARGETARCH=arm64

image-windows:
	$(MAKE) image-only TARGETOS=windows TARGETARCH=amd64

push:
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

clean:
#	rm -rf kbot kbot.exe
	@$(foreach p,$(PLATFORMS),\
		platform_tag=$(subst /,-,$(p)); \
		docker rmi $(REGISTRY)/$(APP):$(VERSION)-$$platform_tag 2>/dev/null || true; )
