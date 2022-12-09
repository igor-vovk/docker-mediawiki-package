#!/bin/bash

MW_DIR=/var/www/mediawiki

echo "Symlinking all user extensions to extensions directory"
for i in $MW_DIR/user-extensions/*; do
    if [ -d "$i" ]; then
        ln -s $i $MW_DIR/extensions/$(basename $i)
    fi
done

echo "Symlink all user skins to skins directory"
for i in $MW_DIR/user-skins/*; do
    if [ -d "$i" ]; then
        ln -s $i $MW_DIR/skins/$(basename $i)
    fi
done

echo "Running apache..."
apache2ctl -D FOREGROUND