# Install Operating system and dependencies
FROM ubuntu:22.04 as build

RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

WORKDIR /build
COPY assets ./assets
COPY lib ./lib
COPY test ./test
COPY web ./web
COPY .metadata analysis_options.yaml pubspec.lock pubspec.yaml ./
RUN flutter build web

# Container to run application
FROM nginx:1.29.1-alpine

WORKDIR /usr/share/nginx/html
COPY --from=build /build/build/web .
