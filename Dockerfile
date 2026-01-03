FROM golang:1.22-alpine

# Répertoire de travail
WORKDIR /app

# Outils nécessaires à la récupération/build
RUN apk add --no-cache \
    ca-certificates \
    wget \
    curl \
    jq \
    tar \
    build-base

# Variables par défaut (surchargées par docker-compose si besoin)
ENV CODEBERG_API_BASE="https://codeberg.org/api/v1"
ENV PROXYGUARD_REPO="eduVPN/proxyguard"
ENV PROXYGUARD_BASE_URL="https://codeberg.org/eduVPN/proxyguard/archive"
ENV PROXYGUARD_RELEASES_URL="https://codeberg.org/eduVPN/proxyguard/releases"

# Si vide -> on ira chercher la dernière release à chaque démarrage
ENV PROXYGUARD_VERSION=""

# Paramètres réseau par défaut
ENV LISTEN_ADDR="127.0.0.1:51821"
ENV TO="127.0.0.1:51820"

# Infos HTTP / reverse proxy (pour logs/doc)
ENV PROXYGUARD_HTTP_PREFIX="/proxyguard/vpn.example.org"
ENV VPN_SERVER_NAME="vpn.example.org"

# On copie le script d'entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

