#!/bin/sh

SCRIPT_PATH="$(realpath $0)"
SCRIPT_DIR="$(dirname $SCRIPT_PATH)"

cd "$SCRIPT_DIR/public_html"
php -S localhost:8000
