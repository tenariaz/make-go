APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/tenariaz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS?=linux
TARGETARCH?=amd64
IMAGE_TAG=$(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)
PLATFORMS=linux_amd64 linux_arm64 windows_amd64 darwin_amd64 darwin_arm64
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
	make build TARGETOS=linux TARGETARCH=amd64

linux-arm:
	make build TARGETOS=linux TARGETARCH=arm64

macos:
	make build TARGETOS=darwin TARGETARCH=amd64

macos-arm:
	make build TARGETOS=darwin TARGETARCH=arm64

windows:
	make build TARGETOS=windows TARGETARCH=amd64
	mv kbot kbot.exe

image:
# 	docker build \
# 		--build-arg TARGETOS=$(TARGETOS) \
# 		--build-arg TARGETARCH=$(TARGETARCH) \
# 		-t $(IMAGE_TAG) .
	@for platform in $(PLATFORMS); do \
		os=$$(echo $$platform | cut -d_ -f1); \
		arch=$$(echo $$platform | cut -d_ -f2); \
		docker buildx build \
			--platform $$os/$$arch \
			--build-arg TARGETOS=$$os \
			--build-arg TARGETARCH=$$arch \
			--output type=docker \
			--tag $(REGISTRY)/$(IMAGE_NAME):$$platform \
			. ; \
	done

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
	@for platform in $(PLATFORMS); do \
		docker rmi $(REGISTRY)/$(IMAGE_NAME):$$platform 2>/dev/null || true; \
	done
	# rm -rf kbot kbot.exe
	# @docker rmi $(shell docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^$(REGISTRY)/$(APP):$(VERSION)") 2>/dev/null || true
