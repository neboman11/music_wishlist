FROM public/flutter/dart:3.7.0-sdk3.7.0

WORKDIR /app

COPY .metadata analysis_options.yaml pubspec.lock pubspec.yaml ./