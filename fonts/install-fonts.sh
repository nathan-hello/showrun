#!/bin/bash

this_dir="$(dirname "$(realpath "$0")")"
temp_dir="$this_dir/tmp"
font_dir="$HOME/.local/share/fonts"

mkdir -p "$font_dir"

for file in *.zip; do
    unzip -d "$temp_dir" "$file"
done

cp "$temp_dir"/*.otf "$font_dir"

fc-cache -fv
