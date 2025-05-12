IMAGE_NAME := us-east1-docker.pkg.dev/gecko-admin/gecko-admin/atlantis
IMAGE_TAG := 0.34.3
IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: build
build:
	@docker build --platform linux/amd64 -t ${IMAGE} .

.PHONY: push
push: build
	@docker push ${IMAGE}
