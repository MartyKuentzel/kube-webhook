NAME = mutateme
IMAGE_PREFIX = 3236527
IMAGE_NAME = $$(basename `pwd`)
IMAGE_VERSION = $$(git log --abbrev-commit --format=%h -s | head -n 1)

export GO111MODULE=on

app: deps
	go build -v -o $(NAME) cmd/main.go

deps:
	go get -v ./...

test: deps
	go test -v ./... -cover
	
docker:
	docker build -t $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_VERSION) .
	docker tag $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_PREFIX)/$(IMAGE_NAME):latest

push:
	docker push $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_VERSION) 
	docker push $(IMAGE_PREFIX)/$(IMAGE_NAME):latest

kind:
	kind create cluster --config kind.yaml

deploy:
	kubectl apply -f deploy/webhook.yaml

reset:
	kubectl delete -f deploy/webhook.yaml
	kubectl apply -f deploy/webhook.yaml

delete:
	kubectl delete -f deploy/webhook.yaml

.PHONY: docker push kind deploy reset
