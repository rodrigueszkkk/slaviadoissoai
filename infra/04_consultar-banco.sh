#!/bin/bash
# =====================================================================
# 04 - Evidências no banco em nuvem ("SELECT" direto no MongoDB do ACI)
#      Aplica o script.sql (coleções/índices) e consulta as coleções.
# Execução:
#   chmod +x 04_consultar-banco.sh
#   ./04_consultar-banco.sh aplicar     # aplica o script.sql no banco
#   ./04_consultar-banco.sh consultar   # SELECT em Grupos, Trabalhos e Users
# =====================================================================
set -e
DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$DIR/00_variaveis.sh"

AUTH="-u $MONGO_USER -p $MONGO_PASSWORD --authenticationDatabase admin"

case "$1" in
  aplicar)
    # Envia o script.sql (em base64) para dentro do container e executa com mongosh
    SQL_B64=$(base64 -w0 "$DIR/../script.sql")
    az container exec \
      --resource-group "$RESOURCE_GROUP_NAME" \
      --name "$MONGO_ACI_NAME" \
      --exec-command "/bin/bash -c \"echo $SQL_B64 | base64 -d > /tmp/script.js && mongosh $AUTH /tmp/script.js\""
    ;;
  consultar)
    az container exec \
      --resource-group "$RESOURCE_GROUP_NAME" \
      --name "$MONGO_ACI_NAME" \
      --exec-command "mongosh $AUTH $MONGO_DB --eval \"printjson(db.Grupos.find().toArray()); printjson(db.Trabalhos.find().toArray()); printjson(db.Users.find({}, {senha:0}).toArray())\""
    ;;
  *)
    echo "Uso: $0 [aplicar|consultar]"
    exit 1
    ;;
esac
