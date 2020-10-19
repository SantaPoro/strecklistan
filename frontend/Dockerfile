FROM nginx:alpine

LABEL maintainer="Joakim Hulthe <joakim@hulthe.net>"

# Remove this when nginx adds webassembly as a mimetype
RUN sed -i "/types {/a application/wasm  wasm;" /etc/nginx/mime.types

# Add a script for generating /etc/nginx/start_time.conf and starting nginx
RUN echo $'#!/bin/sh\n\
# Get the current time in a Last-Modified compatible format
# and save it too an nginx-config file
TZ="GMT" LANG="en_GB.UTF-8" date "+set \$nginx_start_time \\\"%a, %d %b %Y %H:%M:%S GMT\\\";" > /etc/nginx/start_time.conf \n\
nginx -g "daemon off;" '\
> /start.sh;\
chmod +x /start.sh

CMD "/start.sh"

RUN rm /etc/nginx/conf.d/*
COPY prod.nginx.conf /etc/nginx/conf.d/custom.conf

COPY index.html /usr/share/nginx/html/index.html
COPY pkg /usr/share/nginx/html/pkg
COPY static /usr/share/nginx/html/static
