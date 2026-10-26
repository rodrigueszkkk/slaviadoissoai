#!/bin/bash
# =====================================================================
# Variáveis comuns aos scripts de infraestrutura (FIAP NEXT - Checkpoint 3)
# Uso: os demais scripts fazem "source ./00_variaveis.sh"
#
# ANTES DE EXECUTAR (Cloud Shell - Bash):
#   az account show
#   az account set --subscription "nome-da-assinatura-correta"
#
# SEGREDOS NÃO FICAM NESTE ARQUIVO. Opcionalmente defina no terminal:
#   export MONGO_PASSWORD='SenhaForte123'      # apenas letras e números
#   export JWT_SECRET='uma-chave-com-no-minimo-32-caracteres-123'
# Se não definir, o script 02 gera valores aleatórios e salva em infra/.segredos.env
# (arquivo ignorado pelo Git).
# =====================================================================

RM="561760"                                   # ALTERE PARA SEU RM
LOCATION="eastus"                              # ALTERE conforme sua Policy (brazilsouth, eastus, ...)

RESOURCE_GROUP_NAME="rg-fiapnext-$RM"

# Banco de dados em nuvem (MongoDB em Container - ACI)
MONGO_ACI_NAME="aci-mongo-fiapnext"
MONGO_DNS_LABEL="mongo-fiapnext-$RM"          # FQDN: <label>.<regiao>.azurecontainer.io
MONGO_IMAGE="mongo:7"
ACR_NAME="acrfiapnext$RM"                     # Azure Container Registry (fallback quando o Docker Hub falha)
MONGO_USER="fiapnext"
MONGO_DB="FiapNextDb"

# Aplicação (Azure App Service Linux)
APP_SERVICE_PLAN="plan-fiapnext-$RM"
WEBAPP_NAME="fiapnext-api-$RM"                # URL: https://<WEBAPP_NAME>.azurewebsites.net
RUNTIME="DOTNETCORE:10.0"                     # confirme com: az webapp list-runtimes --os-type linux
SKU="B1"                                      # F1 (gratuito) também funciona se a assinatura permitir

# Carrega segredos gerados anteriormente, se existirem
SEGREDOS_FILE="$(dirname "${BASH_SOURCE[0]}")/.segredos.env"
if [ -f "$SEGREDOS_FILE" ]; then
  # shellcheck disable=SC1090
  source "$SEGREDOS_FILE"
fi
