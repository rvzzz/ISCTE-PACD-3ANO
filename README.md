# ISCTE PACD 3º Ano

Este repositório guarda os artefactos de apoio do projecto de caracterização dos terminais intermodais em Lisboa. Neste checkout não estão incluídos os dados brutos; o que existe aqui são ficheiros de contexto, mapeamento espacial, relatórios e scripts de auditoria.

## Conteúdo

- `grelha.geojson`: geometria da grelha usada no projecto.
- `GRUPO_15.pdf`: poster de comunicação do grupo.
- `PFACD_2025_2026_G15___Caracterização_dos_terminais_intermodais_em_Lisboa.pdf`: relatório principal do projecto.
- `bash scripts/`: utilitários para inspecionar os CSV e guardar os relatórios gerados.

## Pasta `bash scripts/`

A pasta contém:

- `audit_csv.sh`: percorre ficheiros CSV recursivamente, mostra cabeçalhos, primeiras/últimas linhas e assinala cabeçalhos anómalos.
- `count_csvs.sh`: conta linhas por CSV.
- `raw_data_tree.txt`: árvore textual da estrutura de dados original usada como referência.
- `relatorio_audit_csv.txt`: saída do audit aos CSV.
- `relatorio_count_csvs.txt`: saída da contagem de linhas por CSV.

## Como usar os scripts

```bash
bash "bash scripts/audit_csv.sh" .
bash "bash scripts/count_csvs.sh" .
```

Notas:

- `audit_csv.sh` usa `python3` para validar o formato do cabeçalho.
- `count_csvs.sh` chama `xan count`, por isso o utilitário `xan` tem de estar instalado.

