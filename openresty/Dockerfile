FROM openresty/openresty:alpine

# Install perl (required for opm)
RUN apk add --no-cache perl curl

# Install resty.http using OpenResty package manager
RUN opm get ledgetech/lua-resty-http

# Copy configuration and Lua script
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY access.lua /usr/local/openresty/nginx/lua/access.lua
