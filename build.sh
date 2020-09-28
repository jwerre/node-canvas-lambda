read -p "Node Version (default: 12) "  VERSION
VERSION=${VERSION:-12}
# echo $VERSION

docker build \
--build-arg NODE_VERSION="$VERSION" \
-t canvas-layers .

docker run -d --rm \
--mount type=bind,source="$(pwd)",target=/out canvas-layers \
/out/layers.zip \
/root/layers

# wait for the zip file to complete
echo "Compressing Layers..."
while [ ! -f ./layers.zip ]; do sleep 1; done

unzip -o ./layers.zip -d .

read -p "Would you like to upload the layers to AWS [Yy]?" -n 1 -r

echo # /n
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

aws lambda publish-layer-version \
--layer-name "node${VERSION}CanvasLib64" \
--zip-file "fileb://root/layers/node${VERSION}_canvas_lib64_layer.zip" \
--description "Node canvas lib 64"

aws lambda publish-layer-version \
--layer-name "node${VERSION}chartjsCanvas" \
--zip-file "fileb://root/layers/node${VERSION}_canvas_layer.zip" \
--description "A Lambda Layer which includes node canvas, chart.js, chartjs-node-canvas, chartjs-plugin-datalabels"

rm layers.zip && rm -rf root