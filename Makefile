NODE_VERSION=12

help:
	@echo "Usage:"
	@echo " make help                -- display this help"
	@echo " make build               -- Build the layers using docker"
	@echo " make upload-layers       -- Upload the layer to AWS"
	@echo " make lambda-tests        -- Test the layers in lambda docker"
	@echo " make clean               -- Remove built layers"

build:
	docker build --build-arg NODE_VERSION="${NODE_VERSION}" \
		--tag node${NODE_VERSION}-canvas-layers .
	mkdir -p build
	docker create -ti --name dummy node${NODE_VERSION}-canvas-layers bash
	docker cp dummy:/root/layers/node${NODE_VERSION}_canvas_lib64_layer.zip build/
	docker cp dummy:/root/layers/node${NODE_VERSION}_canvas_layer.zip build/
	docker rm -f dummy

upload-layers: build upload-lib upload-nodejs

upload-lib:
	aws lambda publish-layer-version \
	--layer-name "node${NODE_VERSION}CanvasLib64" \
	--compatible-runtimes nodejs${NODE_VERSION}.x \
	--zip-file "fileb://build/node${NODE_VERSION}_canvas_lib64_layer.zip" \
	--description "Node canvas lib 64"

upload-nodejs:
	aws lambda publish-layer-version \
	--layer-name "node${NODE_VERSION}Canvas" \
	--compatible-runtimes nodejs${NODE_VERSION}.x \
	--zip-file "fileb://build/node${NODE_VERSION}_canvas_layer.zip" \
	--description "A Lambda Layer which includes node canvas, chart.js, chartjs-node-canvas, chartjs-plugin-datalabels"

lambda-test: unzip-layers
	docker run --rm \
		--volume "$$(pwd)":/var/task:ro,delegated \
		--volume "$$(pwd)/lib":/opt/lib:ro,delegated \
		--volume "$$(pwd)/nodejs":/opt/nodejs:ro,delegated \
		lambci/lambda:nodejs${NODE_VERSION}.x test.handler

lambda-test-bash: unzip-layers
	docker run --rm -it \
		--volume "$$(pwd)":/var/task \
		--volume "$$(pwd)/lib":/opt/lib \
		--volume "$$(pwd)/nodejs":/opt/nodejs \
	  lambci/lambda:build-nodejs${NODE_VERSION}.x bash

unzip-layers: build
unzip-layers: nodejs
unzip-layers: lib

nodejs:
	unzip build/node${NODE_VERSION}_canvas_layer.zip

lib:
	unzip build/node${NODE_VERSION}_canvas_lib64_layer.zip

clean:
	rm -rf build lib nodejs
