# node-canvas-lambda

A node-canvas layer for AWS Lambda

## Install

### AWS Console
1.  Clone the repository
1.  Log into AWS console and navigate to Lambda service
1.  Click **Layers** in the sidebar
1.  Click **Create layer**
1.  Give the layer a name, description and upload the `node10_canvas_layer.zip`
1.  Click **Create**
1.  Follow the previous 3 steps and create a layer for `canvas-lib64-layer.zip`
1.  Click **Functions** in the sidebar
1.  Select your function in the function list
1.  Click **Layers** in the Designer panel
1.  In the Layers panel click **Add a layer**.
1.  In the Layers panel click **Add a layer**.
1.  Choose **Select from list of runtime compatible layers**, select the layer Name and Version and click **Add**.

### AWS CLI

Clone the repository and follow the steps below.

```zsh

cd node-cavnas-lambda

aws s3 cp ./node10_canvas_layer.zip s3://<MY BUCKET>/node-canvas-layer.zip
aws s3 cp ./canvas-lib64-layer.zip s3://<MY BUCKET>/canvas-lib64-layer.zip

aws lambda publish-layer-version 
	--layer-name nodeCanvasLayer \
	--description A node-canvas layer \
	--content S3Bucket=<MY BUCKET>,S3Key=node-canvas-layer.zip,S3ObjectVersion=1

aws lambda publish-layer-version 
	--layer-name nodeCanvasLayer \
	--description A node-canvas layer \
	--content S3Bucket=<MY BUCKET>,S3Key=canvas-lib64-layer.zip,S3ObjectVersion=1

```


## Why do I need to install `canvas-lib64-layer.zip`?

AWS Lambda [documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html ) specifies that AWS Lambda uses the amzn2-ami-hvm-2.0.20190313-x86_64-gp2 AMI. This is clearly not the case otherwise `/usr/lib64` would be the same in both environment. However if you set up a simple canvas function it will run on the AMI but will throw the following error in Lambda.

```js
Error: libuuid.so.1: cannot open shared object file: No such file or directory
    at Module.load (internal/modules/cjs/loader.js:600:32)
    at tryModuleLoad (internal/modules/cjs/loader.js:539:12)
    at Function.Module._load (internal/modules/cjs/loader.js:531:3)
    at Module.require (internal/modules/cjs/loader.js:637:17)
    at require (internal/modules/cjs/helpers.js:22:18)
    at Object.<anonymous> (/var/task/node_modules/canvas/lib/bindings.js:3:18)
    at Module._compile (internal/modules/cjs/loader.js:701:30)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:712:10)
    at Module.load (internal/modules/cjs/loader.js:600:32)
```

If you compare `/usr/lib64` inside a Lambda function and cross-reference it with the Amazon AMI you'll find that there are 5 libraries missing in the Lambda environment. Here are the missing libraries which are packaged in `canvas-lib64-layer.zip`:

`libblkid.so.1`, `libmount.so.1` , `libuuid.so.1` , `libfontconfig.so.1`, `libpixman-1.so.0`


## How to create these layers yourself

### 1. Create the docker container

You'll need to install Docker on your local system if you don't have it then run the following:

```zsh
docker build -t canvas-layers .
docker run -d --rm --mount type=bind,source="$(pwd)",target=/out canvas-layers /out/layers.zip /root/layers
```
<!-- 
```zsh
docker run -it amazonlinux:latest /bin/bash
```

### 2. Install 

```zsh
yum groupinstall "Development Tools" -y
curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
yum install -y nodejs
# I don't think this is necessary
yum install cairo-devel libjpeg-turbo-devel giflib-devel pango-devel -y
```

### 3. Create Node Canvas layer

```zsh
mkdir ~/nodejs
cd ~/nodejs
npm install --build-from-source canvas
/* npm install canvas@next */
```

### 4. Create library layer

```zsh
mkdir ~/lib
cd ~/lib
cp /lib64/libblkid.so.1 .
cp /lib64/libmount.so.1 .
cp /lib64/libuuid.so.1 .
cp -P /lib64/libfontconfig.so* .
cp -P /lib64/libpixman-1.so* .
```

### 5. Archive layers

```zsh
cd ~
zip -r9 canvas-layer.zip nodejs
zip -r9 canvas-lib64-layer.zip lib
### 6. In a new terminal window copy layer archives out of Docker container
```zsh
docker ps # note the container id
docker cp <CONTAINER ID>:/root/canvas-layer.zip ./canvas-layer.zip
docker cp <CONTAINER ID>:/root/canvas-lib64-layer.zip ./canvas-lib64-layer.zip
```
``` -->
