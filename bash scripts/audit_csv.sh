#!/usr/bin/env bash
# =============================================================================
#  audit_csv.sh
#  Percorre recursivamente a pasta actual e imprime info básica sobre cada CSV.
# =============================================================================

# ── Cores ─────────────────────────────────────────────────────────────────────
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
BLUE='\033[34m'
MAGENTA='\033[35m'
RESET='\033[0m'

# ── Configuração ──────────────────────────────────────────────────────────────
ROOT="${1:-.}"                   # Pasta raiz (argumento ou directório actual)
SEP="────────────────────────────────────────────────────────────────────────"

# ── Contadores ────────────────────────────────────────────────────────────────
total=0
anomalos=0

# ── Banner ────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}${SEP}${RESET}"
echo -e "${BOLD}${BLUE}  CSV Audit — Terminais Intermodais Lisboa${RESET}"
echo -e "${BOLD}${BLUE}  Pasta raiz: ${CYAN}$(realpath "$ROOT")${RESET}"
echo -e "${BOLD}${BLUE}${SEP}${RESET}\n"

# ── Função principal ──────────────────────────────────────────────────────────
audit_csv() {
    local file="$1"
    local relpath="${file#$ROOT/}"      # caminho relativo à pasta raiz

    # Lê apenas a primeira linha (header)
    local header
    header=$(head -n 1 "$file")

    # Conta colunas (separador vírgula)
    local ncols
    ncols=$(echo "$header" | awk -F',' '{print NF}')

    # Detecta formato VERDADEIRAMENTE anomalo:
    #   linha inteira encapsulada numa só string  →  "col1,""col2"",""col3"""
    #   Em QUOTE_ALL válido  →  "col1","col2","col3"
    # Critério: em QUOTE_ALL, a primeira aspas fecha ANTES da primeira vírgula:
    #   ^"[^,"]+","  →  abre ", chars sem vírgula nem aspas, depois ","
    # Se começa com " mas NÃO faz match ao padrão acima → anomalo
    local anomalo=false
    local quoted_cols=false
    if [[ "$header" == '"'* ]]; then
        # Usa python para o teste de regex (mais fiável que bash para este caso)
        local is_quote_all
        is_quote_all=$(python3 -c "
import re, sys
h = '''$header'''
print('yes' if re.match(r'^\"[^\",]+\",\"', h) else 'no')
" 2>/dev/null)
        if [[ "$is_quote_all" == "yes" ]]; then
            quoted_cols=true
        else
            anomalo=true
            ((anomalos++))
        fi
    fi

    ((total++))

    # ── Impressão ─────────────────────────────────────────────────────────────
    echo -e "${BOLD}${CYAN}▶ ${relpath}${RESET}"
    echo -e "  ${DIM}Colunas: ${RESET}${BOLD}${ncols}${RESET}"

    if $anomalo; then
        echo -e "  ${RED}⚠  Formato ANOMALO — linha inteira encapsulada (CSV não standard, requer pré-processamento)${RESET}"
        echo -e "  ${DIM}Raw:${RESET} ${YELLOW}${header}${RESET}"
    else
        # Para CSV com QUOTE_ALL: remove as aspas antes de imprimir
        if $quoted_cols; then
            echo -e "  ${DIM}(campos entre aspas — CSV QUOTE_ALL, válido)${RESET}"
        fi
        # Imprime cada coluna numerada em cor
        echo -e -n "  ${DIM}Header:${RESET} "
        IFS=',' read -ra cols <<< "$header"
        for i in "${!cols[@]}"; do
            col="${cols[$i]}"
            # Remove aspas e espaços residuais
            col="${col//\"/}"
            col="${col#"${col%%[![:space:]]*}"}"
            col="${col%"${col##*[![:space:]]}"}"
            num=$((i + 1))
            echo -e -n "${GREEN}${num}${RESET}${DIM}:${RESET}${BOLD}${col}${RESET}"
            if [[ $num -lt $ncols ]]; then
                echo -e -n "${DIM}  │  ${RESET}"
            fi
        done
        echo ""
        # fazer um head das primeiras 5 linhas
        echo -e "  ${DIM}Primeiras 5 linhas:${RESET}"
        head -n 5 "$file" | while IFS= read -r line; do
            echo -e "    ${MAGENTA}${line}${RESET}"
        done

        # fazer um tail das últimas 5 linhas
        echo -e "  ${DIM}Últimas 5 linhas:${RESET}"
        tail -n 5 "$file" | while IFS= read -r line; do
            echo -e "    ${MAGENTA}${line}${RESET}"
        done
    fi

    echo -e "${DIM}  ${SEP:0:68}${RESET}"
}

# ── Percorre todos os CSV recursivamente (ordenado por path) ──────────────────
while IFS= read -r -d '' file; do
    audit_csv "$file"
done < <(find "$ROOT" -type f -iname "*.csv" -print0 | sort -z)

# ── Resumo final ──────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${BLUE}${SEP}${RESET}"
echo -e "${BOLD}  Resumo${RESET}"
echo -e "${BOLD}${BLUE}${SEP}${RESET}"
echo -e "  ${DIM}Total de ficheiros CSV encontrados:${RESET}  ${BOLD}${GREEN}${total}${RESET}"
if [[ $anomalos -gt 0 ]]; then
    echo -e "  ${DIM}Ficheiros com formato anomalo:${RESET}       ${BOLD}${RED}${anomalos}${RESET}"
fi
echo -e "${BOLD}${BLUE}${SEP}${RESET}\n"
