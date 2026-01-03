#!/bin/sh
set -e

echo "[proxyguard] ============================================="
echo "[proxyguard]   ProxyGuard container starting"
echo "[proxyguard] ============================================="

# 1) Déterminer la version à utiliser
if [ -z "${PROXYGUARD_VERSION}" ]; then
  echo "[proxyguard] PROXYGUARD_VERSION non défini."
  echo "[proxyguard] Récupération de la dernière release sur Codeberg..."

  latest_tag=$(
    curl -s "${CODEBERG_API_BASE}/repos/${PROXYGUARD_REPO}/releases?limit=1" \
      | jq -r '.[0].tag_name'
  )

  if [ -z "${latest_tag}" ] || [ "${latest_tag}" = "null" ]; then
    echo "[proxyguard] ERREUR: Impossible de récupérer la dernière release depuis l'API."
    echo "[proxyguard] URL API: ${CODEBERG_API_BASE}/repos/${PROXYGUARD_REPO}/releases?limit=1"
    exit 1
  fi

  PROXYGUARD_VERSION="${latest_tag}"
  echo "[proxyguard] Dernière release trouvée: ${PROXYGUARD_VERSION}"
else
  echo "[proxyguard] PROXYGUARD_VERSION fourni par l'environnement: ${PROXYGUARD_VERSION}"
fi

# 2) Log clair de la version + URL de téléchargement
TARBALL_URL="${PROXYGUARD_BASE_URL}/${PROXYGUARD_VERSION}.tar.gz"

echo "[proxyguard] ============================================="
echo "[proxyguard] Version ProxyGuard   : ${PROXYGUARD_VERSION}"
echo "[proxyguard] URL de téléchargement: ${TARBALL_URL}"
echo "[proxyguard] Page des releases    : ${PROXYGUARD_RELEASES_URL}"
echo "[proxyguard] LISTEN_ADDR          : ${LISTEN_ADDR}"
echo "[proxyguard] TO (WireGuard)       : ${TO}"
echo "[proxyguard] HTTP prefix          : ${PROXYGUARD_HTTP_PREFIX}"
echo "[proxyguard] VPN server name      : ${VPN_SERVER_NAME}"
echo "[proxyguard] ============================================="

# 3) Build si pas déjà compilé pour cette version
if [ -x "/usr/local/bin/proxyguard-server" ] \
   && [ -f "/app/.proxyguard_version" ] \
   && [ "$(cat /app/.proxyguard_version)" = "${PROXYGUARD_VERSION}" ]; then
  echo "[proxyguard] Binaire proxyguard-server déjà présent pour ${PROXYGUARD_VERSION}, on réutilise."
else
  echo "[proxyguard] Build de ProxyGuard ${PROXYGUARD_VERSION}..."

  # On garde juste le fichier de version dans /app, mais on build ailleurs
  echo "${PROXYGUARD_VERSION}" > /app/.proxyguard_version

  BUILD_DIR="/tmp/proxyguard-build"
  rm -rf "${BUILD_DIR}"
  mkdir -p "${BUILD_DIR}"
  cd "${BUILD_DIR}"

  echo "[proxyguard] Téléchargement: ${TARBALL_URL}"
  wget -q -O proxyguard.tar.gz "${TARBALL_URL}"

  echo "[proxyguard] Extraction de l'archive dans ${BUILD_DIR}..."
  # On encapsule tar dans un if pour éviter que set -e fasse tout planter
  if ! tar -xzf proxyguard.tar.gz; then
    echo "[proxyguard] AVERTISSEMENT: Erreurs pendant l'extraction (chmod, FS exotique ?)."
    echo "[proxyguard] Vérification du contenu malgré tout..."
  fi

  SRC_DIR=$(find "${BUILD_DIR}" -maxdepth 1 -type d -name "proxyguard*" | head -n1)
  if [ -z "${SRC_DIR}" ]; then
    echo "[proxyguard] ERREUR: impossible de trouver le répertoire source après extraction."
    exit 1
  fi

  echo "[proxyguard] Répertoire source: ${SRC_DIR}"

  cd "${SRC_DIR}"
  echo "[proxyguard] go build ./cmd/proxyguard-server ..."
  go build -v -o /usr/local/bin/proxyguard-server ./cmd/proxyguard-server

  cd /
  echo "[proxyguard] Build terminé pour ProxyGuard ${PROXYGUARD_VERSION}."
fi

# 4) Lancer le serveur
echo "[proxyguard] ============================================="
echo "[proxyguard] Démarrage de proxyguard-server ..."
echo "[proxyguard] Commande: proxyguard-server --listen \"${LISTEN_ADDR}\" --to \"${TO}\""
echo "[proxyguard] ============================================="

exec /usr/local/bin/proxyguard-server --listen "${LISTEN_ADDR}" --to "${TO}"
