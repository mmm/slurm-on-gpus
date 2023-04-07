
default: version list

NAMESPACE="markmims"
IMAGE=$(shell basename $(PWD))
VERSION=1.10.1

run_ghpc := docker run --rm -t \
	-v $(CURDIR):/workspace \
	--user $(shell id -u):$(shell id -g) \
	markmims/ghpc-dev:latest

%.svg : %.dot
	@echo "---" $@ "---"
	dot -T svg $< -o $@ 

%.pdf : %.html
	@echo "---" $@ "---"
	$(run_decktape) -s '1920x1080' $< $@

version: show-version
show-version:
	@echo "--- $@ $(VERSION) ---"

list: list-images
list-images:
	@echo "--- $@ $(IMAGE) ---"
	@docker images | grep $(IMAGE)

build:
	@echo "--- $@ $(IMAGE) ---"
	docker build -t $(IMAGE) .

tag: tag-version tag-latest 
tag-version:
	@echo "--- $@ $(VERSION) ---"
	docker tag $(IMAGE) $(NAMESPACE)/$(IMAGE):$(VERSION)

tag-latest:
	@echo "--- $@ latest---"
	docker tag $(IMAGE) $(NAMESPACE)/$(IMAGE):latest

publish: push
push: push-version push-latest 
push-version: tag-version
	@echo "--- $@ $(NAMESPACE)/$(IMAGE):$(VERSION) ---"
	docker push $(NAMESPACE)/$(IMAGE):$(VERSION)

push-latest: tag-latest
	@echo "--- $@ $(NAMESPACE)/$(IMAGE):latest ---"
	docker push $(NAMESPACE)/$(IMAGE):latest

run:
	@echo "--- $@ $(IMAGE):latest ---"
	docker run -it --rm $(IMAGE):latest

cluster:
	@echo "--- $@ $(IMAGE) ---"
	$(run_ghpc)  build -t $(IMAGE) .

clean-local-images:
	@echo "--- $@ $(IMAGE) ---"
	@echo "should probably make this clean up any local dev images?"

clean: clean-local-images
	@echo "--- $@ $(IMAGE) ---"
	rm -f *.html
	rm -f *.pdf

clobber: clean

