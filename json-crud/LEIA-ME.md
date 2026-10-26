# JSONs para o CRUD (Swagger / curl)

Autenticação: `POST /api/auth/login` com `01-login-admin.json` → copie o `token` e use `Authorization: Bearer <token>`
(no Swagger: botão **Authorize**, valor `Bearer <token>`).

| Tabela (coleção) | Operação | Rota | Arquivo |
|---|---|---|---|
| Grupos | C | `POST /api/grupos` | `02-grupos-POST.json` |
| Grupos | R | `GET /api/grupos` e `GET /api/grupos/{id}` | – |
| Grupos | U | `PUT /api/grupos/{id}` | `03-grupos-PUT.json` |
| Grupos | D | `DELETE /api/grupos/{id}` | – |
| Trabalhos | C | `POST /api/trabalhos` | `04-trabalhos-POST.json` (troque `grupoId` pelo `id` do grupo criado) |
| Trabalhos | R | `GET /api/trabalhos` e `GET /api/trabalhos/{id}` | – |
| Trabalhos | U | `PUT /api/trabalhos/{id}` | `05-trabalhos-PUT.json` |
| Trabalhos | D | `DELETE /api/trabalhos/{id}` | – |

Após **cada** operação, rode o SELECT equivalente no banco em nuvem:

```bash
./infra/04_consultar-banco.sh consultar
```

(ou, dentro do `mongosh`: `db.Grupos.find()` / `db.Trabalhos.find({grupoId: "<id>"})`).
