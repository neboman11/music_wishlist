FROM public/flutter/dart:3.7.0-sdk3.7.0

WORKDIR /app

COPY pubspec.yaml ./
COPY pubspec.lock ./
COPY pubspec.yaml ./ # typo fix - should be yaml