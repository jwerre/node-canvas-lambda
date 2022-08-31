NODE_VERSION=16
TEST_IMG_NAME=canvas-lambda-test

help:
	@echo "Usage:"
	@echo " make help                -- display this help"
	@echo " make build               -- Build the layers using docker"
	@echo " make publish             -- Upload the layer to AWS"
	@echo " make test                -- Test the layers in lambda docker"
	@echo " make clean               -- Remove built layers"

build:
	docker build --build-arg NODE_VERSION="${NODE_VERSION}" \
		--tag node${NODE_VERSION}-canvas-layers .
	mkdir -p build
	docker create -ti --name dummy node${NODE_VERSION}-canvas-layers bash
	docker cp dummy:/root/layers/node${NODE_VERSION}_canvas_lib64_layer.zip build/
	docker cp dummy:/root/layers/node${NODE_VERSION}_canvas_layer.zip build/
	docker rm -f dummy

publish-lib:
	aws lambda publish-layer-version \
	--layer-name "node${NODE_VERSION}CanvasLib64" \
	--compatible-runtimes nodejs${NODE_VERSION}.x \
	--zip-file "fileb://build/node${NODE_VERSION}_canvas_lib64_layer.zip" \
	--description "Node canvas lib 64"

publish-nodejs:
	aws lambda publish-layer-version \
	--layer-name "node${NODE_VERSION}Canvas" \
	--compatible-runtimes nodejs${NODE_VERSION}.x \
	--zip-file "fileb://build/node${NODE_VERSION}_canvas_layer.zip" \
	--description "A Lambda Layer which includes node canvas, chart.js, chartjs-node-canvas, chartjs-plugin-datalabels"

publish: build publish-lib publish-nodejs


# This doesn't work for some reason. It would be nice to use this instead of the 
# test cmd below then we wouldn't need `test.dockerfile`
# docker run -p 9564:8080 --rm -d \
# 	--name ${TEST_IMG_NAME} \
# 	--volume "$$(pwd)":/var/task:ro,delegated \
# 	--volume "$$(pwd)/lib":/opt/lib:ro,delegated \
# 	--volume "$$(pwd)/nodejs":/opt/nodejs:ro,delegated \
# 	public.ecr.aws/lambda/nodejs:16 \
# 	test.handler

test: unzip-layers

	docker run \
		-p 9564:8080 \
		-d \
		--rm \
		--name ${TEST_IMG_NAME} \
		$$( docker build \
			--no-cache \
			--build-arg NODE_VERSION=${NODE_VERSION} \
			--file test.dockerfile \
			-q \
			. \
		)

	echo $$(curl \
		-s \
		-XPOST "http://localhost:9564/2015-03-31/functions/function/invocations" \
		-d '{"message":"Test was successful!"}' \
		| jq '.body' );

	docker stop ${TEST_IMG_NAME}


unzip-layers: build
unzip-layers: nodejs
unzip-layers: lib

nodejs:
	unzip build/node${NODE_VERSION}_canvas_layer.zip

lib:
	unzip build/node${NODE_VERSION}_canvas_lib64_layer.zip

clean:
	rm -rf build lib nodejs
