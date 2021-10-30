# node-canvas-lambda

A node-canvas (and chart.js) layer for AWS Lambda

## Install

*Note:* 
If you're not using Node.js version 12 then you'll need to recompile the layers.
See the Build section below. Also, these layers include chart.js. If you don't
want these modules included you can remove them from the Dockerfile (around line
19) and rebuild the layers.

### AWS Console
1.  Clone the repository
1.  Log into AWS console and navigate to Lambda service
1.  Click **Layers** in the sidebar
1.  Click **Create layer**
1.  Give the layer a name, description and upload the `node12_canvas_layer.zip`
1.  Click **Create**
1.  Follow the previous 3 steps and create a layer for `node12_canvas-lib64-layer.zip`
1.  Click **Functions** in the sidebar
1.  Select your function in the function list
1.  Click **Layers** in the Designer panel
1.  In the Layers panel click **Add a layer**.
1.  Choose **Select from list of runtime compatible layers**, select the layer
Name and Version and click **Add**.

### AWS CLI

Clone the repository and follow the steps below.

```zsh

aws lambda publish-layer-version \
--layer-name "node12CanvasLib64" \
--zip-file "fileb://node12_canvas_lib64_layer.zip" \
--description "Node canvas lib 64"

aws lambda publish-layer-version \
--layer-name "node12Canvas" \
--zip-file "fileb://node12_canvas_layer.zip" \
--description "A Lambda Layer which includes node canvas, chart.js, chartjs-node-canvas, chartjs-plugin-datalabels"

```

## Build

Build new layers using the Dockerfile and copy them to the build folder.
Be sure to have Docker installed then run the following command:

```zsh
make build
```

To build for a different node version set the `NODE_VERSION`:

```zsh
make build NODE_VERSION=10
```

## Upload

Upload the layers to AWS into your default region. This will build the layers
if they have not already been built.

```zsh
make upload-layers
```

## Test

A lambda image (e.g. `lambci/lambda:nodejs12.x` ) can be used to test the layers
by loading the layers and running a simple lambda handler that uses canvas.

The following command will unzip the layers and mount the layer folders into to
the `/opt/` folder of the lambda container and then run the `test.js` handler:

```zsh
make lambda-test
```

## Debug

A lambda build image (e.g. `lambci/lambda:build-nodejs12.x`) can be used to
debug any issues with the layers.

Use `make lambda-test-bash` to start an interactive bash session in a lambda
container where you can use `ldd` or [lddtree](https://github.com/ncopa/lddtree)
to examine the `canvas.node` binary:

```zsh
ldd /opt/nodejs/node_modules/canvas/build/Release/canvas.node
```
