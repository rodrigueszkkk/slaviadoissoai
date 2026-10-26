#!/bin/bash
# =====================================================================
# 02 - Cria o BANCO DE DADOS EM NUVEM: MongoDB em Container (Azure Container Instances)
#      A senha entra como variável de ambiente SEGURA (não aparece no portal/logs).
# Execução:
#   chmod +x 02_criar-banco-mongo-aci.sh && ./02_criar-banco-mongo-aci.sh
# =====================================================================
set -e
DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$DIR/00_variaveis.sh"

# Gera segredos aleatórios caso não tenham sido informados
if [ -z "$MONGO_PASSWORD" ]; then
  MONGO_PASSWORD="$(openssl rand -hex 12)"
  GEROU_SEGREDOS=1
fi
if [ -z "$JWT_SECRET" ]; then
  JWT_SECRET="$(openssl rand -hex 32)"
  GEROU_SEGREDOS=1
fi
if [ -n "$GEROU_SEGREDOS" ]; then
  umask 077
  printf "MONGO_PASSWORD='%s'\nJWT_SECRET='%s'\n" "$MONGO_PASSWORD" "$JWT_SECRET" > "$DIR/.segredos.env"
  echo ">> Segredos gerados e salvos em infra/.segredos.env (NÃO versionar). Use-os nas variáveis secretas da Pipeline."
fi

criar_aci() {
  az container create     --resource-group "$RESOURCE_GROUP_NAME"     --name "$MONGO_ACI_NAME"     --image "$1"     --os-type Linux     --cpu 1     --memory 2     --ports 27017     --ip-address Public     --dns-name-label "$MONGO_DNS_LABEL"     --restart-policy Always     --environment-variables MONGO_INITDB_ROOT_USERNAME="$MONGO_USER" MONGO_INITDB_DATABASE="$MONGO_DB"     --secure-environment-variables MONGO_INITDB_ROOT_PASSWORD="$MONGO_PASSWORD"     "${@:2}"
}

echo ">> Criando container MongoDB ($MONGO_IMAGE) no ACI direto do Docker Hub (até 3 tentativas)"
CRIADO=0
for i in 1 2 3; do
  if criar_aci "$MONGO_IMAGE"; then CRIADO=1; break; fi
  echo ">> Tentativa $i falhou (Docker Hub). Aguardando 20s..."
  sleep 20
done

if [ "$CRIADO" -ne 1 ]; then
  echo ">> Docker Hub indisponível. Usando o Azure Container Registry (ACR) como origem da imagem"
  az container delete --resource-group "$RESOURCE_GROUP_NAME" --name "$MONGO_ACI_NAME" --yes 2>/dev/null || true
  az acr create     --resource-group "$RESOURCE_GROUP_NAME"     --name "$ACR_NAME"     --sku Basic     --admin-enabled true
  az acr import     --name "$ACR_NAME"     --source "docker.io/library/$MONGO_IMAGE"     --image "$MONGO_IMAGE"     --force
  ACR_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
  ACR_USER=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
  ACR_PASS=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)
  criar_aci "$ACR_SERVER/$MONGO_IMAGE"     --registry-login-server "$ACR_SERVER"     --registry-username "$ACR_USER"     --registry-password "$ACR_PASS"
fi

MONGO_FQDN=$(az container show \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$MONGO_ACI_NAME" \
  --query ipAddress.fqdn -o tsv)

echo ""
echo ">> MongoDB disponível em: $MONGO_FQDN:27017"
echo ">> Connection string (guarde em variável SECRETA da Pipeline - MONGO_CONNECTION):"
echo "   mongodb://$MONGO_USER:<MONGO_PASSWORD>@$MONGO_FQDN:27017/?authSource=admin"
echo ">> (a senha real está em infra/.segredos.env ou na variável MONGO_PASSWORD)"
