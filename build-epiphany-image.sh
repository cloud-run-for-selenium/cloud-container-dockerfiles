#!/bin/sh
BUILD_DATE=$(date +'%Y%m%d')

docker build -f Dockerfile.epiphany.nginx -t jamesmortensen/webkitwebdriver-epiphany-cloud:latest .
docker tag jamesmortensen/webkitwebdriver-epiphany-cloud:latest jamesmortensen/webkitwebdriver-epiphany-cloud:$BUILD_DATE
