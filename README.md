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

## Build - Docker

The build script included in this repo will compile new layers and (optionally)
uploaded them to AWS into your default region. Be sure to have Docker installed
then run the follwing command:

```zsh
./build.sh
```

## Build - CodePipeline

Instead of building locally using Docker, you can build the layer on Amazon itself:

- Create a new CodeCommit repository, and push this repository to it.
- Create a new S3 bucket with versioning enabled to hold the built layers
- Create a new CodePipeline that sources from the CodeCommit repository, uses the latest version
  of Amazon Linux 2, and deploys to the S3 bucket (tick the "extract file before deploy" box).

When the pipeline completes you'll have "node_canvas_lib64_layer.zip" and "node14_canvas_layer.zip"
files in your S3 bucket, ready to be downloaded and published as with the "AWS CLI" method.

To change the version of Node to build for, or the version of Canvas to build, you can add environment 
variables to the CodePipeline Build stage like so:

NODE_VERSION: 14
CANVAS_VERSION: v2.7.0

The canvas version can be set to any git commit hash, branch, or tag [from the node-canvas repository](https://github.com/Automattic/node-canvas)