FROM amazonlinux:latest

ARG LIBS=/usr/lib64
ARG OUT=/root/layers
ARG NODE_VERSION=10

# set up container
RUN yum -y update
RUN yum -y groupinstall "Development Tools"
RUN curl --silent --location https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN yum install -y nodejs cairo cairo-devel cairomm-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel giflib-devel

# will be created and become working dir
WORKDIR $OUT/nodejs

RUN npm install canvas@next
RUN npm install chartjs-plugin-datalabels chartjs-node-canvas chart.js


# RUN ls -al $LIBS

# will be created and become working dir
WORKDIR $OUT/lib
# gather missing libraries
RUN cp $LIBS/libblkid.so.1 .
RUN cp $LIBS/libmount.so.1 .
RUN cp $LIBS/libuuid.so.1 .
RUN cp $LIBS/libfontconfig.so.1 .
RUN cp $LIBS/libpixman-1.so.0 .

# RUN ls -al

WORKDIR $OUT
RUN zip -r -9 canvas-layer.zip nodejs
RUN zip -r -9 canvas-lib64-layer.zip lib

ENTRYPOINT ["zip","-r","-9"]
CMD ["/out/layers.zip", $OUT]
