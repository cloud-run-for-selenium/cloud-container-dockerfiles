#!/bin/bash

ARCH=$1
BASE=$2
TAG=$3

if [ -z "$1" ]; then
    echo ""
    echo "Usage: docker-build.sh arch browser target_image_name"
    echo ""
    echo "Options:"
    echo "- arch:              arm64 | amd64"
    echo "- browser:           chromium | chrome | epiphany | minibrowser"
    echo "- target_image_name: hostname/image_name:tag"
    echo "* (note: chrome for amd64 and chromium for arm)"
    echo "Example: docker-build.sh arm64 chromium jamesmortensen/standalone-chromium-cloud-arm64:latest"
    echo ""
    echo "This would build from base image selenium/standalone-chromium:latest and then the built image"
    echo "would be jamesmortensen/standalone-chromium-cloud-arm64:latest"
    echo ""
    exit 1
fi

if [ "$ARCH" = "amd64" ]; then
    if [ "$BASE" = "chrome" ]; then
        FROM_ENTRY="selenium/standalone-chrome:latest"
    elif [ "$BASE" = "epiphany" ]; then
        FROM_ENTRY="jamesmortensen/webkitwebdriver-epiphany:latest"
    elif [ "$BASE" = "minibrowser" ]; then
        FROM_ENTRY="jamesmortensen/webkitwebdriver-minibrowser:latest"
    fi

elif [ "$ARCH" = "arm64" ]; then
    if [ "$BASE" = "chromium" ]; then
        FROM_ENTRY="seleniarm/standalone-chromium:latest"
    elif [ "$BASE" = "epiphany" ]; then
        FROM_ENTRY="jamesmortensen/webkitwebdriver-epiphany:latest"
    elif [ "$BASE" = "minibrowser" ]; then
        FROM_ENTRY="jamesmortensen/webkitwebdriver-minibrowser:latest"
    fi

else
    echo "Architecture must be amd64 or arm64..."
    echo "You may also optionally specify an image tag as the second argument"
    exit 1;
fi

if [ -z "$3" ]; then
   TAG="jamesmortensen/standalone-$BASE-cloud-$ARCH:latest"
else
   TAG="$3"
fi


# docker buildx build --platform linux/$1 -f Dockerfile.multi --build-arg FROM=$FROM_ENTRY -t $TAG .
podman build -f Dockerfile.multi --build-arg FROM=$FROM_ENTRY -t $TAG .
