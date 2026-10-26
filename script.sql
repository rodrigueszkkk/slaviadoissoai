// =====================================================================
// script.sql - DDL do banco FiapNextDb (MongoDB / NoSQL)
//
// O MongoDB não usa SQL: o "DDL" é composto por createCollection (com validação
// $jsonSchema), índices e o relacionamento Trabalhos.grupoId -> Grupos._id.
// O arquivo é executado com o mongosh e é IDEMPOTENTE (pode rodar mais de uma vez):
//
//   ./infra/04_consultar-banco.sh aplicar
//   (ou, direto no container:  mongosh -u <user> -p <senha> --authenticationDatabase admin script.sql)
//
// Modelo (equivalente relacional):
//   Grupos    (_id PK, nome, turma, integrantes[], dataCriacao)
//   Trabalhos (_id PK, titulo, descricao, categoria, linkRepositorio, linkPitch,
//              grupoId FK -> Grupos._id, nota, relevancia, dataSubmissao)   -- N:1 com Grupos
//   Users     (_id PK, nome, email UNIQUE, senha, role)
// =====================================================================

use("FiapNextDb");

function garantirColecao(nome, validador, indices) {
  const opcoes = { validator: validador, validationLevel: "moderate", validationAction: "warn" };
  if (db.getCollectionNames().includes(nome)) {
    db.runCommand({ collMod: nome, ...opcoes });
  } else {
    db.createCollection(nome, opcoes);
  }
  indices.forEach(i => db.getCollection(nome).createIndex(i.chaves, i.opcoes || {}));
}

// ---------------------------------------------------------------------
// CREATE TABLE Grupos
// ---------------------------------------------------------------------
garantirColecao("Grupos", {
  $jsonSchema: {
    bsonType: "object",
    required: ["_id", "nome", "turma", "integrantes", "dataCriacao"],
    properties: {
      _id:         { bsonType: "string", description: "Guid (PK)" },
      nome:        { bsonType: "string", minLength: 2 },
      turma:       { bsonType: "string", minLength: 1 },
      integrantes: { bsonType: "array", minItems: 1, items: { bsonType: "string" } },
      dataCriacao: { bsonType: "date" }
    }
  }
}, [
  { chaves: { nome: 1 } }
]);

// ---------------------------------------------------------------------
// CREATE TABLE Trabalhos   (grupoId = chave estrangeira para Grupos._id)
// ---------------------------------------------------------------------
garantirColecao("Trabalhos", {
  $jsonSchema: {
    bsonType: "object",
    required: ["_id", "titulo", "descricao", "categoria", "linkRepositorio", "linkPitch",
               "grupoId", "nota", "relevancia", "dataSubmissao"],
    properties: {
      _id:             { bsonType: "string", description: "Guid (PK)" },
      titulo:          { bsonType: "string", minLength: 3 },
      descricao:       { bsonType: "string", minLength: 10 },
      categoria:       { bsonType: "string" },
      linkRepositorio: { bsonType: "string" },
      linkPitch:       { bsonType: "string" },
      grupoId:         { bsonType: "string", description: "FK -> Grupos._id" },
      nota:            { bsonType: ["decimal", "double", "int"], minimum: 0, maximum: 10 },
      relevancia:      { bsonType: ["decimal", "double", "int"], minimum: 0, maximum: 100 },
      dataSubmissao:   { bsonType: "date" }
    }
  }
}, [
  { chaves: { titulo: 1 } },
  { chaves: { nota: 1 } },
  { chaves: { relevancia: 1 } },
  { chaves: { grupoId: 1 } }          // índice da chave estrangeira
]);

// ---------------------------------------------------------------------
// CREATE TABLE Users
// ---------------------------------------------------------------------
garantirColecao("Users", {
  $jsonSchema: {
    bsonType: "object",
    required: ["_id", "nome", "email", "senha", "role"],
    properties: {
      _id:   { bsonType: "string" },
      nome:  { bsonType: "string" },
      email: { bsonType: "string" },
      senha: { bsonType: "string" },
      role:  { enum: ["Admin", "Usuario"] }
    }
  }
}, [
  { chaves: { email: 1 }, opcoes: { unique: true } }
]);

print("Colecoes: " + db.getCollectionNames().join(", "));
