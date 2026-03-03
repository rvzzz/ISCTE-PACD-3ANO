#!/bin/bash

# Diretório base: argumento ou diretório atual
BASE_DIR="${1:-.}"

echo "============================================"
echo "COUNT DE LINHAS POR FICHEIRO CSV"
echo "Base: $BASE_DIR"
echo "============================================"

while IFS= read -r -d '' file; do
    count=$(xan count "$file")
    printf "%-80s %s\n" "$file" "$count"
done < <(find "$BASE_DIR" -type f -iname "*.csv" -print0 | sort -z)

