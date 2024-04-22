APP=$(shell basename $(shell git remote get-url origin) | tr '[:upper:]' '[:lower:]')
REGISTRY=ghcr.io/stassweepy
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=amd64

DOCKER_LOGIN_CMD = echo "$(DOCKERHUB_REGISTRY_TOKEN)" | docker login -u $(DOCKERHUB_USERNAME)

linux:
	$(MAKE) image TARGETOS=linux TARGETARCH=${TARGETARCH}

windows:
	$(MAKE) image TARGETOS=windows TARGETARCH=${TARGETARCH}

macos:
	$(MAKE) image TARGETOS=darwin TARGETARCH=${TARGETARCH}

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build:
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o bot -ldflags '-X="github.com/StasSweepy/testbot1/cmd.appVersion=${VERSION}"'

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg=TARGETOS=${TARGETOS} --build-arg=TARGETARCH=${TARGETARCH}

push:
	$(DOCKER_LOGIN_CMD)
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -rf bot
	docker rmi -f ${REGISTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}
