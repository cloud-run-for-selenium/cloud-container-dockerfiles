# Cloud Container Dockerfiles

This repository contains Dockerfiles to build container images for container-based platforms, such as Heroku and Google Cloud Run

## Building WebkitWebDriver MiniBrowser Cloud Container

Heroku has a nice free plan with no credit card to get started, but Chrome and Firefox require more resources than what the free plan allows. However, MiniBrowser, a webkitGTK-based browser which runs well in low memory environments. It uses the same engine as Apple Safari.

To run on Heroku, we add an NGINX reverse proxy. The reverse proxy sends traffic meant for noVNC to the noVNC server on port 7900, and WebKitWebDriver traffic to port 4444.  The reverse proxy listens publicly on the port exposed by the container-based platform.

### Security

When running on Heroku, the container looks for the following environment variables set in the Heroku Config Vars:

- ACCESS_TOKEN - This is a token which must be sent as an authorization Bearer token when making requests.
- VNC_SECRET_PW - This is the password to access the VNC server via HTTPS.

With these variables set, the server is secured from outside abuse.

### Pushing and Deploying to Heroku

Login to the Heroku Container Registry:

```
$ heroku container:login
```

Add a Heroku-compatible tag for the container image:

```
$ docker tag jamesmortensen/webkitwebdriver-epiphany-cloud:latest registry.heroku.com/YOUR_APP/web:latest
```

Push the image to the registry:

```
$ docker push registry.heroku.com/YOUR_APP/web:latest
```

Deploy the image:

```
$ heroku container:release web -a YOUR_APP
```

Once deployed, visit YOUR_APP.herokuapp.com. You will see a 401 Unauthorized page if the deployment is successful. If you've already added the VNC_SECRET_PW and ACCESS_TOKEN to your Heroku Config Vars, you'll need to install the [ModHeader Chrome Extension](https://chrome.google.com/webstore/detail/modheader/idgpnmonknjnojddfkpgkljpfnnfcklj?hl=en) and then add the ACCESS_TOKEN as an authorization header Bearer token.

Once added, you'll see the noVNC client when visiting YOUR_APP.herokuapp.com

## Building Selenium Cloud Containers, based on docker-selenium

### Generate Dockerfile and build the image

The Selenium organization maintains [docker-selenium](https://github.com/SeleniumHQ/docker-selenium) images which contain a Selenium server, WebDriver, and a web browser. These images can also be run on Google Cloud Run and other platforms, but if the platform only supports one open public port, then we need a way to route traffic to those services through a single port. This can be accomplished with reverse proxies, such as NGINX or Caddy.

When running on Google Cloud Run or Heroku, the image needs the NGINX proxy installed in order to forward traffic from the open port to services listening on internal local ports. Run these commands to generate the Dockerfile and build the image for Chrome:

```
$ sh docker-build-image.sh amd64 chrome jamesmortensen/standalone-chrome-cloud:latest
$ docker build -t jamesmortensen/standalone-chrome-cloud:latest .
```


### Seleniarm Standalone Chromium arm64

In some cases you may want to deploy to a non x86_64 cloud platform, or even just explore the image locally on an arm device, such as Mac M1. For example, for the experimental arm64 or armhf seleniarm images, the commands would follow this pattern:

```
$ sh docker-build-image.sh arm64 chromium jamesmortensen/standalone-chromium-cloud-arm64:latest
$ docker build -t jamesmortensen/standalone-chromium-cloud-arm64:latest .
```

Heroku and Cloud Run don't support arm at this time, but this helps solve building for other platforms which do.

## Run the containers locally

The exposed public PORT is set at runtime, usually by the cloud platform provider. When running locally, we pass the PORT as both an environment variable, so the nginx.conf can be generated properly, and we pass the port to docker's -p argument to open the port between the host and the container. 

The containers are designed to be run securely, so we also need to set an ACCESS_TOKEN. Optionally, we can change the VNC password by setting the VNC_SECRET_PW environment variable. By default, it's just "secret". Below is an example command to run the Chrome Cloud Container locally:

```
$ docker run --rm -it -p 8080:8080 --shm-size 3g -e PORT=8080 -e ACCESS_TOKEN=abcde jamesmortensen/standalone-chrome-cloud:latest
```

Be sure to create a profile in ModHeaders extension in order to pass the ACCESS_TOKEN via the Authorization header by entering "Bearer ${ACCESS_TOKEN}" and replacing ${ACCESS_TOKEN} with the actual token. ("abcde" in the above example).

When running in the cloud, you should use a GUID-generating tool or find some way to create a longer, randomized token for better security.

Access the container via http://localhost:8080. Browsing to the root path loads up the noVNC server, while browsing to http://localhost:8080/status will return the status of the Selenium server. Any requests to http://localhost:8080/wd/hub/


## License

Copyright (c) James Mortensen, 2021-2022 Apache License v2.0

