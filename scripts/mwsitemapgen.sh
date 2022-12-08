#!/bin/bash
MW_HOME=/var/www/mediawiki

Help() {
    echo "MediaWiki sitemap generator"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help"
    echo "  -s, --server SERVER, e.g. https://example.com"
    echo "  -i, --identifier IDENTIFIER"
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            Help
            ;;
        -s|--server)
            MW_SITE_SERVER="$2"
            shift
            ;;
        -i|--identifier)
            MW_SITEMAP_IDENTIFIER="$2"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            Help
            ;;
    esac
    shift
done

echo "Starting sitemap generator..."
rm $MW_HOME/sitemap/*

php $MW_HOME/maintenance/generateSitemap.php \
    --fspath=$MW_HOME/sitemap/ \
    --urlpath=/sitemap/ \
    --compress=yes \
    --server=$MW_SITE_SERVER \
    --skip-redirects \
    --identifier=$MW_SITEMAP_IDENTIFIER

echo "Creating symlink to /sitemap.xml..."
rm -f $MW_HOME/sitemap.xml
find $MW_HOME/sitemap/ -type f -name "sitemap*.xml" -exec ln -s {} $MW_HOME/sitemap.xml \;
