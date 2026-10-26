#!/bin/bash
# =====================================================================
# 99 - Remove TODOS os recursos do projeto (execute só após a correção/entrega!)
# =====================================================================
source "$(dirname "${BASH_SOURCE[0]}")/00_variaveis.sh"
az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait
