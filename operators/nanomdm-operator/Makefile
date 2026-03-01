IMAGE ?= ghcr.io/suzutan/nanomdm-operator
TAG ?= latest

.PHONY: build push run

build:
	docker build -t $(IMAGE):$(TAG) .

push: build
	docker push $(IMAGE):$(TAG)

run:
	kopf run --standalone main.py
