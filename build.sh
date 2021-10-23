read -p "Node Version (default: 12) "  VERSION
VERSION=${VERSION:-12}
# echo $VERSION

make build

read -p "Would you like to upload the layers to AWS [Yy]?" -n 1 -r

echo # /n
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

make upload-layers clean
