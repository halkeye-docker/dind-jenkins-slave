.DEFAULT_GOAL := build

NAME = dind-jenkins-slave
TAGNAME = halkeye/$(NAME)
VERSION = 3.40-1-dind-1

build: ## Build docker image
	docker build -t $(TAGNAME):$(VERSION) .

push: ## push to docker hub
	docker push $(TAGNAME):$(VERSION)

run:
	docker run -it --rm --privileged --name $(NAME) $(TAGNAME):$(VERSION)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
