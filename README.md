# Tiny MediaWiki Docker Container

https://www.mediawiki.org/

This container is based on [Canasta](https://github.com/CanastaWiki/Canasta) package and takes some stuff from it.

Few problems that didn't allow me to use it:
* SQLite support
* this container uses latest version of MediaWiki at the moment, 1.39.0

## Attaching extensions and skins
This image supports attaching extensions and skins via volumes.
To attach extensions and skins, symlink them to `/var/www/mediawiki/user-extensions` and `/var/www/mediawiki/user-skins` respectively:
```yaml
services:
  wiki:
    image: ghcr.io/igor-vovk/docker-mediawiki-package:main
    restart: unless-stopped
    volumes:
      - ./user-extensions:/var/www/mediawiki/user-extensions
      - ./user-skins:/var/www/mediawiki/user-skins

...
```

## Sitemap generation
This image relies on external scheduler to trigger sitemap generation.
The image provides `/mwsitemapgen.sh` script to trigger the generation.

See this `docker-compose.yml` example, which uses [Ofelia](https://hub.docker.com/r/mcuadros/ofelia) scheduler:
```yaml
version: '3'

services:
  ofelia:
    image: mcuadros/ofelia:latest
    restart: unless-stopped
    command: daemon --docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - wiki
  wiki:
    image: ghcr.io/igor-vovk/docker-mediawiki-package:main
    restart: unless-stopped
    volumes:
      ...
      - sitemap:/var/www/mediawiki/sitemap
    labels:
      - ofelia.enabled=true
      - ofelia.job-exec.sitemap.schedule=@every 1h
      - ofelia.job-exec.sitemap.command=/mwsitemapgen.sh --server https://example.com --identifier examplecom

volumes:
  sitemap:
```