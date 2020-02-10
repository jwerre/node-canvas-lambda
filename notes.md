# How to Create layers

## 1. Create the docker image
```zsh
docker run -it amazonlinux:latest /bin/bash
```

## 2. Install Node

```zsh
yum groupinstall "Development Tools" -y
curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
yum install -y nodejs
yum install cairo-devel libjpeg-turbo-devel giflib-devel pango-devel -y
```

## 3. Create Canvas Layer

```zsh
mkdir ~/nodejs
cd ~/nodejs
npm install canvas@next
```

## 4. Create Library Layer

```zsh
mkdir ~/lib
cd ~/lib
cp /lib64/libblkid.so.1 .
cp /lib64/libmount.so.1 .
cp /lib64/libuuid.so.1 .
cp /lib64/libfontconfig.so.1.7.0 .
ln -s libfontconfig.so.1.7.0 libfontconfig.so
ln -s libfontconfig.so.1.7.0 libfontconfig.so.1
```
## 5. Archive Layers

```zsh
cd ~
zip -r9 canvas-layer.zip
zip -r9 canvas-lib64-layer.zip
```
	
docker ps
docker cp 241f0754116b:/root/canvas-layer.zip ~/Desktop/canvas-layer.zip
docker cp 241f0754116b:/root/canvas-lib64-layer.zip ~/Desktop/canvas-lib64-layer.zip
