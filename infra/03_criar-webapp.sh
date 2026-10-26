#!/bin/bash
# =====================================================================
# 03 - Cria o Plano de Serviço e o Web App (Linux) que receberá o deploy da Pipeline.
#      As variáveis de ambiente da aplicação (Mongo / JWT) são gravadas como App Settings.
# Execução:
#   chmod +x 03_criar-webapp.sh && ./03_criar-webapp.sh
# =====================================================================
set -e
source "$(dirname "${BASH_SOURCE[0]}")/00_variaveis.sh"

if [ -z "$MONGO_PASSWORD" ] || [ -z "$JWT_SECRET" ]; then
  echo "ERRO: MONGO_PASSWORD/JWT_SECRET não definidos. Execute antes o script 02 (ou exporte as variáveis)." >&2
  exit 1
fi

echo ">> Runtimes .NET disponíveis no App Service Linux (confirme se $RUNTIME existe):"
az webapp list-runtimes --os-type linux | grep -i "DOTNETCORE" || true

echo ">> Criando App Service Plan $APP_SERVICE_PLAN ($SKU, Linux)"
az appservice plan create \
  --name "$APP_SERVICE_PLAN" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku "$SKU" \
  --is-linux

echo ">> Criando Web App $WEBAPP_NAME"
az webapp create \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --plan "$APP_SERVICE_PLAN" \
  --runtime "$RUNTIME"

MONGO_FQDN=$(az container show \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$MONGO_ACI_NAME" \
  --query ipAddress.fqdn -o tsv)

echo ">> Gravando variáveis de ambiente (App Settings)"
az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --settings \
    ASPNETCORE_ENVIRONMENT="Production" \
    MongoDb__ConnectionString="mongodb://$MONGO_USER:$MONGO_PASSWORD@$MONGO_FQDN:27017/?authSource=admin" \
    MongoDb__DatabaseName="$MONGO_DB" \
    Jwt__SecretKey="$JWT_SECRET" \
  --output none

az webapp restart --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP_NAME"

echo ">> Web App criado: https://$WEBAPP_NAME.azurewebsites.net"
