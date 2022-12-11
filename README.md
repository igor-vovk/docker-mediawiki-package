# `igor-vovk/tiny-mediawiki`
> Tiny [MediaWiki](https://www.mediawiki.org/) Docker Image

Image: [`ghcr.io/igor-vovk/tiny-mediawiki`](https://ghcr.io/igor-vovk/tiny-mediawiki)

Project aim is to support following features:
* SQLite support
* use latest version of MediaWiki engine (`1.39.0` at the moment)

# Installation
1. Create `database`, `images`, `user-skins`, `user-extensions` directories.
2. Create `docker-compose.yml` file:
```yaml
version: '3'

services:
  wiki:
    image: ghcr.io/igor-vovk/tiny-mediawiki:main
    restart: unless-stopped
    ports:
      - 8080:80
    volumes:
      - ./database:/var/www/data
      - ./images:/var/www/mediawiki/images
      - ./user-extensions:/var/www/mediawiki/user-extensions
      - ./user-skins:/var/www/mediawiki/user-skins
```
3. Run `docker-compose up -d`
4. Open [`http://localhost:8080/mw-config/index.php`](http://localhost:8080/mw-config/index.php) in your browser and follow installation instructions.
5. Choose SQLite database and set `/var/www/data` as database directory. In the end of the installation, save the `LocalSettings.php` file and put it in the directory with your `docker-compose.yml` file.
6. Add your `LocalSettings.php` file to the `docker-compose.yml` file:
```yaml
...
    volumes:
      - ./database:/var/www/data
      - ./images:/var/www/mediawiki/images
      - ./user-extensions:/var/www/mediawiki/user-extensions
      - ./user-skins:/var/www/mediawiki/user-skins
      - ./LocalSettings.php:/var/www/mediawiki/LocalSettings.php
```
7. Run `docker-compose up -d` again. You are good to go!

## Attaching extensions and skins
This image supports attaching extensions and skins via volumes.
To attach extensions and skins, symlink them to `/var/www/mediawiki/user-extensions` and `/var/www/mediawiki/user-skins` respectively:

```yaml
services:
  wiki:
    image: ghcr.io/igor-vovk/tiny-mediawiki:main
    restart: unless-stopped
    volumes:
      - ./user-extensions:/var/www/mediawiki/user-extensions
      - ./user-skins:/var/www/mediawiki/user-skins

...
```

> Note: after making changes to extensions or skins, you need to run `docker-compose up -d` again, because they are linked during the startup.


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
    image: ghcr.io/igor-vovk/tiny-mediawiki:main
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