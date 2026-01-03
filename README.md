# proxyguard-auto-docker

# Conteneur ProxyGuard auto-version (Alpine)

Ce projet fournit un conteneur Docker pour `proxyguard-server` qui :

- récupère automatiquement la **dernière release** sur Codeberg si `PROXYGUARD_VERSION` n'est pas défini,
- permet de **figer une version** avec la variable d'environnement `PROXYGUARD_VERSION`,
- affiche en log la **version utilisée** et l'URL de téléchargement,
- lance `proxyguard-server --listen LISTEN_ADDR --to TO`.

## Liens utiles

- [Page ProxyGuard](https://codeberg.org/eduVPN/proxyguard)
- [Releases ProxyGuard](https://codeberg.org/eduVPN/proxyguard/releases)

## Utilisation en local

```bash
docker compose up --build
```

Par défaut, la dernière release ProxyGuard est utilisée (auto-détection via l'API Codeberg).

Pour figer une version :

```bash
environment:
  - PROXYGUARD_VERSION=v2.0.1
```
