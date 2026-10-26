#!/bin/bash
# =====================================================================
# 01 - Registra os providers e cria o Resource Group do projeto
# Execução (Cloud Shell - Bash):
#   chmod +x 01_criar-grupo-recursos.sh && ./01_criar-grupo-recursos.sh
# =====================================================================
set -e
source "$(dirname "${BASH_SOURCE[0]}")/00_variaveis.sh"

echo ">> Assinatura em uso:"
az account show --query "{Assinatura:name, Id:id}" -o table

echo ">> Registrando providers utilizados"
az provider register --namespace Microsoft.Web
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ContainerRegistry

echo ">> Criando Resource Group $RESOURCE_GROUP_NAME em $LOCATION"
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION"
