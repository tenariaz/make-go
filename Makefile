REGISTRY=quay.io/projectquay
IMAGE_NAME=test-app
DIST_DIR=dist

PLATFORMS=linux_amd64 linux_arm64 windows_amd64 darwin_amd64 darwin_arm64

.PHONY: all clean $(PLATFORMS)

all: $(PLATFORMS)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

linux_amd64:
	$(MAKE) build-platform OS=linux ARCH=amd64

linux_arm64:
	$(MAKE) build-platform OS=linux ARCH=arm64

# windows_amd64:
# 	$(MAKE) build-platform OS=windows ARCH=amd64

darwin_amd64:
	$(MAKE) build-darwin OS=darwin ARCH=amd64

darwin_arm64:
	$(MAKE) build-darwin OS=darwin ARCH=arm64

build-platform:
	docker buildx build \
		--platform $(OS)/$(ARCH) \
		--build-arg TARGETOS=$(OS) \
		--build-arg TARGETARCH=$(ARCH) \
		--output type=docker \
		--tag $(REGISTRY)/$(IMAGE_NAME):$(OS)_$(ARCH) \
		.

build-darwin: $(DIST_DIR)
	@echo "🛠 Building darwin binary for $(ARCH)..."
	GOOS=$(OS) GOARCH=$(ARCH) CGO_ENABLED=0 go build -o $(DIST_DIR)/app-$(OS)-$(ARCH) .

windows_amd64:
	$(MAKE) build-windows OS=windows ARCH=amd64

build-windows: $(DIST_DIR)
	@echo "🛠 Building Windows binary for $(ARCH)..."
	GOOS=$(OS) GOARCH=$(ARCH) CGO_ENABLED=0 go build -o $(DIST_DIR)/app-$(OS)-$(ARCH).exe .


image:
	@for platform in $(IMAGE_PLATFORMS); do \
		os=$$(echo $$platform | cut -d_ -f1); \
		arch=$$(echo $$platform | cut -d_ -f2); \
		echo "🐳 Building Docker image for $$platform..."; \
		docker buildx build \
			--platform $$os/$$arch \
			--build-arg TARGETOS=$$os \
			--build-arg TARGETARCH=$$arch \
			--output type=docker \
			--tag $(REGISTRY)/$(IMAGE_NAME):$$platform \
			. ; \
	done

clean:
	docker rmi $(REGISTRY)/$(IMAGE_NAME) 2>/dev/null || true;
	docker rmi $(shell docker image ls --format '{{.Repository}}:{{.Tag}}' | grep "^$(REGISTRY)/$(APP)") 2>/dev/null || true
