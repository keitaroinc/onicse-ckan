#!/bin/bash
set -ex
CKAN__PLUGINS=$(cat $EXT_WHEEL_DIR/default_extensions.txt)
extensions=$(cat $EXT_WHEEL_DIR/extensions.txt)
for extension in $extensions; do
    echo "Installing extension: $extension"
    pip install --no-index --find-links=$EXT_WHEEL_DIR $extension
done
extensions=$(cat $EXT_WHEEL_DIR/extension_ini_names.txt)
echo $extensions
for extension_ini_name in $extensions; do
    echo $extensions
    CKAN__PLUGINS+=" $extension_ini_name"
done
echo $CKAN__PLUGINS

ckan config-tool ${APP_DIR}/production.ini "ckan.plugins = ${CKAN__PLUGINS}"
# export CKAN__PLUGINS=${CKAN__PLUGINS}