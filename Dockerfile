# Étape 1 : Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copier les dépendances d'abord (cache Docker optimisé)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copier le reste du code
COPY . .

# Construire pour le web
RUN flutter build web --release

# Étape 2 : Servir avec nginx (image légère)
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
