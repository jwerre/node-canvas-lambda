ARG NODE_VERSION=12
FROM lambci/lambda:build-nodejs${NODE_VERSION}.x

ARG LIBS=/usr/lib64
ARG OUT=/root/layers
ARG NODE_VERSION=12

# set up container
RUN yum -y update \
&& yum -y groupinstall "Development Tools" \
&& yum install -y gcc-c++ cairo-devel libjpeg-turbo-devel pango-devel giflib-devel
# && yum install -y nodejs cairo cairo-devel cairomm-devel libjpeg-turbo-devel pango pango-devel pangomm pangomm-devel giflib-devel

RUN node --version

# will be created and become working dir
WORKDIR $OUT/nodejs

RUN npm install canvas \
chartjs-plugin-datalabels \
chartjs-node-canvas \
chart.js --build-from-source

# will be created and become working dir
WORKDIR $OUT/lib

# gather missing libraries
RUN curl https://raw.githubusercontent.com/ncopa/lddtree/v1.26/lddtree.sh -o $OUT/lddtree.sh \
&& chmod +x $OUT/lddtree.sh \
&& cp $($OUT/lddtree.sh -l $OUT/nodejs/node_modules/canvas/build/Release/canvas.node | grep '^\/lib' | sed -r -e '/canvas.node$/d') .

WORKDIR $OUT

RUN zip -r -9 node${NODE_VERSION}_canvas_layer.zip nodejs \
&& zip -r -9 node${NODE_VERSION}_canvas_lib64_layer.zip lib
