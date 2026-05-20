# Étape 1 : Build Flutter Web avec une version récente
FROM ghcr.io/cirruslabs/flutter:3.32.2 AS builder

# Éviter l'erreur "running flutter as root"
ENV FLUTTER_ROOT=/opt/flutter
USER root

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get --no-version-check || flutter pub get

COPY . .
RUN flutter build web --release

# Étape 2 : Servir avec nginx
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
