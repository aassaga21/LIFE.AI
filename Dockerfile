# Étape 1 : Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.32.2 AS builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Étape 2 : Servir avec nginx + config SPA
FROM nginx:alpine

# Config nginx avec support Flutter Web routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers buildés
COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
