# node-canvas-lambda

A node-canvas (and chart.js) layer for AWS Lambda


## Build

Build new layers using the Dockerfile and copy them to the build folder.
Be sure to have Docker installed then run the following command:

```zsh
make build
```

The default version of Nodejs is 16. To build for a different node version set
the `NODE_VERSION`:

```zsh
make build NODE_VERSION=14
```

## Publish

Upload the layers to AWS into your default region. This will build the layers
if they have not already been built.

```zsh
make publish
```

## Test

A lambda image (e.g. `public.ecr.aws/lambda/nodejs:16-arm64` ) can be used to
test the layers by loading the layers and running a simple lambda handler that
uses canvas.

The following command will unzip the layers and mount the layer folders into to
the `/opt/` folder of the lambda container and then run the `test.js` handler:

```zsh
make test
```

If the test worked correctly the output should be a data URI.
e.g.: `"data:image/png;base64,iVBORw0KGgoAAAA...`. You can copy the URI and
paste it into our browser's url bar to see the image.

## Architecture

**The default architecture for these layers are ARM**. If you're function uses
amd64 architecute you shouldn't have any issues. If you're using `x86-64` you'll
need to checkout the `x86-64` branch and run `make build`.

## Debug

The build image can be used to debug any issues with the layers.

Use `make debug` to start an interactive bash session in the container where you
can use `ldd` or [`lddtree`](https://github.com/ncopa/lddtree) to examine the
`canvas.node` binary:

```zsh
ldd nodejs/node_modules/canvas/build/Release/canvas.node
```
