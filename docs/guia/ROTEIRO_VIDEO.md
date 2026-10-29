# Roteiro detalhado do vídeo (YouTube – mínimo 720p, sem cortes, narrado)

> "O vídeo é a evidência da entrega." Grave a tela inteira, fale o que está fazendo e deixe cada tela visível por 3–5 segundos.
> Duração esperada: 25 a 40 minutos. Se errar, **não corte**: repita a cena narrando ("vou refazer este passo").

---

## 0. Antes de apertar o REC

### Estado que precisa estar pronto
| Item | Como conferir |
|---|---|
| Infra criada (RG, ACI Mongo, Web App) | Portal Azure → Resource groups → `rg-fiapnext-561760` |
| `script.sql` aplicado | `./04_consultar-banco.sh aplicar` rodou sem erro |
| Código no Azure Repos com `azure-pipeline.yml`, `infra/`, `script.sql`, `Dockerfile`, `docker-compose.yml`, `json-crud/` | Repos → Files |
| Políticas na `main` (1 revisor, work item obrigatório, revisor padrão) | Repos → Branches → `main` → Branch policies |
| Pipeline já executada manualmente com sucesso (passos 04 e 05) | Pipelines → run verde |
| Task **Active**, atribuída a você, com a branch criada | Boards → Work items |
| `main` **ainda sem** a alteração do passo 06 | `Trabalho.cs` sem `EhDestaque`, sem `/wellcome` |
| Professor adicionado (Basic + Project Administrator) | Organization settings → Users |

### Preparação da tela
- Janela do navegador em tela cheia, zoom 110–125% para o texto ficar legível no vídeo.
- Abas abertas, nesta ordem: **1** Azure DevOps (Boards) · **2** Azure DevOps (Repos/Pipelines) · **3** Portal Azure · **4** Swagger da API · **5** Cloud Shell (Bash, já dentro da pasta `infra`).
- Feche abas pessoais, e-mail, WhatsApp. Desative notificações do Windows.
- **Nunca exiba**: `cat .segredos.env`, a connection string, o valor de `JWT_SECRET`/`MONGO_PASSWORD`. Se o Cloud Shell mostrar a senha, vai para o vídeo público/não listado.
- Tenha o token do login **copiado só na hora** (cena 10). Ele expira.
- Deixe aberto num bloco de notas os textos que você vai colar (JSONs da cena 10/11 e o conteúdo dos arquivos da cena 4), para não perder tempo digitando.

### Ferramenta de gravação
OBS Studio ou Xbox Game Bar (Win+G) / Clipchamp. Saída 1280x720 ou 1920x1080, microfone testado (grave 10 s e ouça antes).

---

## Cena 1 – Apresentação (≈ 1 min)
**Tela:** capa do projeto no Azure DevOps (Overview/Summary).
**Fale:**
> "Somos o grupo **<nome do grupo>**, da turma 2TDSPV. Integrantes: Gabriel Costa Solano (RM562325), Leandro Guarido (RM561760) e Kaiky Pereira Rodrigues (RM564578). Este é o Checkpoint 3 de DevOps: pipelines CI/CD. A solução é a API FIAP NEXT em .NET 10 com banco MongoDB, publicada no Azure App Service por uma pipeline YAML no Azure DevOps. O banco roda em um container no Azure Container Instances."

## Cena 2 – Azure Boards (≈ 1 min)
**Tela:** Boards → Work items → abra a Task.
**Mostre e fale:**
- Título: "Implementar FIAP NEXT API (.NET + MongoDB) no Azure DevOps".
- **Assigned To**: seu nome. **State: Active**.
- Anote o número da Task em voz alta (ex.: "Task 12"). Vai ser usado nos commits.

## Cena 3 – Azure Repos: branch e políticas (≈ 2 min)
**Tela:** Repos → Branches.
1. Mostre a branch `feature/destaque-trabalho` criada a partir da Task (na Task, seção *Development* aparece o link da branch).
2. Em `main` → **⋯ → Branch policies** e role mostrando, um por um:
   - ☑ **Require a minimum number of reviewers = 1** (e "Allow requestors to approve their own changes" marcado).
   - ☑ **Check for linked work items = Required**.
   - ☑ **Automatic reviewers** com seu usuário (RM561760), Required.
3. Fale: "a `main` está protegida; nenhuma alteração entra sem PR, revisor e work item."

## Cena 4 – Passo 06: alteração de código ponta a ponta (≈ 5 min)
Trabalhe **na branch** `feature/destaque-trabalho` (confirme no seletor de branch, canto superior esquerdo do Repos → Files). Edite pelo próprio Repos (Files → arquivo → **Edit**). Não é no README.

### 4.1 Regra de negócio – `FiapNext.Domain/Entities/Trabalho.cs`
Localize o método `private static void ValidarUrl` e, **antes dele**, cole:
```csharp
    // Regra de negócio: trabalho em destaque no festival (nota >= 8 e relevância >= 70)
    public bool EhDestaque() => Nota >= 8.0m && Relevancia >= 70.0m;
```
Clique **Commit**. Mensagem:
```
Adiciona regra de trabalho em destaque #12
```
(troque `12` pelo número da sua Task; o `#` cria o vínculo com o work item). Confirme que o campo **Branch name** é a branch da Task.

### 4.2 Testes – `FiapNext.Tests.Unit/Domain/TrabalhoDestaqueTests.cs`
Na pasta `FiapNext.Tests.Unit/Domain` → **⋯ → New → File** → nome `TrabalhoDestaqueTests.cs`. Cole o conteúdo de `guia/alteracao-codigo/TrabalhoDestaqueTests.cs` (4 testes). Commit:
```
Adiciona testes unitarios de EhDestaque #12
```

### 4.3 Rota nova – `FiapNext.Api/Program.cs`
Antes da linha `app.MapAuthEndpoints();` cole:
```csharp
// Rota incluída - API somente GET em /wellcome
app.MapGet("/wellcome", () => Results.Text("Rota adicionada"))
   .WithName("Wellcome")
   .WithTags("Health")
   .Produces<string>(StatusCodes.Status200OK);
```
Commit:
```
Adiciona rota GET /wellcome #12
```
**Fale** o que cada alteração faz: "a regra marca como destaque o trabalho com nota maior ou igual a 8 e relevância maior ou igual a 70; os testes cobrem os 4 casos; e a rota /wellcome vai provar o deploy na nuvem".

## Cena 5 – Pull Request e fechamento da Task (≈ 3 min)
1. Repos → **Pull requests → New pull request**. Origem `feature/destaque-trabalho` → destino `main`.
2. Título: `Regra EhDestaque + rota /wellcome`. Descrição: 2 linhas do que mudou.
3. Mostre: o **revisor padrão** já adicionado e o **Work item linkado** (Task 12). Clique **Create**.
4. Você mesmo clica **Approve** (ou "Approve with suggestions"). Mostre as políticas ficando verdes.
5. Clique **Complete**. Na janela:
   - Merge type: *Merge (no fast-forward)* (ou Squash).
   - **☐ Delete feature branch after merging → DESMARCADO** ← pedido do professor, fale em voz alta.
   - **☑ Complete associated work items after merging** → fecha a Task.
6. Confirme **Complete merge**. Depois vá a Boards e mostre a Task em **Closed/Done**, e em Repos → Branches mostre que a branch **continua lá**.

## Cena 6 – Passo 07: CI automático (≈ 4 min)
**Tela:** Pipelines → a execução que **começou sozinha** após o merge (mostre "Triggered by / Individual CI" e o commit do merge).
1. Abra o stage **CI – Build e Testes** → job **Build and Test**. Abra o log de **cada** task (um clique em cada, 3–5 s):
   - Instalar .NET 10 · Restaurar pacotes (restore) · Compilar (build) · **Testes unitários** · Publicar (publish) · Compactar · Publicar artefato.
2. Aba **Tests**: mostre **54 testes passando**, e filtre/procure `TrabalhoDestaqueTests` para mostrar os 4 novos.
3. Aba **Summary**: artefato `app` publicado.
**Fale:** "o merge na main disparou o CI automaticamente, sem eu clicar em Run".

## Cena 7 – Passo 07: CD automático (≈ 3 min)
**Tela:** o stage **CD – Release no App Service** iniciando sozinho após o CI.
1. Abra o job **Deploy da API** e o log de cada step: *Baixar artefato do CI* · *Configurar variáveis de ambiente* (AzureAppServiceSettings) · *Deploy da API no App Service* (mostre "Successfully deployed").
2. Em **Pipelines → Edit → Variables** (ou no botão *Variables*): mostre `MONGO_CONNECTION` e `JWT_SECRET` com **cadeado/valor oculto**. Não clique em "mostrar".
**Fale:** "as credenciais estão como variáveis secretas protegidas; o log mostra *** no lugar".

## Cena 8 – Portal Azure (≈ 2 min)
**Tela:** portal.azure.com → Resource groups → `rg-fiapnext-561760`.
1. Mostre os recursos: **Container instance** (`aci-mongo-fiapnext`), **App Service plan**, **App Service** (`fiapnext-api-561760`). Se usou o ACR de fallback, mostre-o também.
2. Fale: "todos criados por script Azure CLI no Cloud Shell, não pelo portal".
3. Abra o App Service → **Settings → Environment variables / Configuration**: mostre os nomes `MongoDb__ConnectionString`, `MongoDb__DatabaseName`, `Jwt__SecretKey`, `ASPNETCORE_ENVIRONMENT` com valores ocultos (não clique em "Show value").
4. Abra o Container instance e mostre o **FQDN**/status *Running*.

## Cena 9 – Aplicação na nuvem (≈ 2 min)
1. `https://fiapnext-api-561760.azurewebsites.net/wellcome` → deve aparecer **Rota adicionada** (prova o código novo no ar).
2. `https://fiapnext-api-561760.azurewebsites.net/health` → `Healthy`.
3. `https://fiapnext-api-561760.azurewebsites.net/` → Swagger com todas as rotas (Auth, Grupos, Trabalhos).
(O primeiro acesso pode levar alguns segundos – cold start. Fale "aguardando o App Service iniciar".)

---

## Cena 10 – CRUD da tabela **Grupos** (≈ 6 min)

Lado a lado: **Swagger** (aba 4) e **Cloud Shell** (aba 5). Rode o SELECT **após cada operação**:
```bash
./04_consultar-banco.sh consultar
```
(Ele imprime Grupos, Trabalhos e Users; mostre o trecho de `Grupos` e narre o que mudou.)

### 10.0 Autenticação (necessária para as rotas protegidas)
- Swagger → `POST /api/auth/login` → **Try it out** → corpo:
```json
{
  "email": "admin@fiap.com.br",
  "senha": "Admin@123"
}
```
- **Execute** → resposta 200 com `token`. Copie o token **sem as aspas**.
- Botão **Authorize** (cadeado, topo) → valor: `Bearer <cole-o-token>` → Authorize → Close.

### 10.1 SELECT inicial (estado antes)
Cloud Shell: `./04_consultar-banco.sh consultar`.
**Fale:** "Grupos tem só o grupo de exemplo do seed". Guarde a ideia do que já existe para comparar depois.

### 10.2 CREATE – `POST /api/grupos`
Corpo (`json-crud/02-grupos-POST.json`):
```json
{
  "nome": "Equipe DevOps CP06",
  "turma": "2TDSPV",
  "integrantes": [
    "Gabriel Costa Solano (RM562325)",
    "Leandro Guarido (RM561760)",
    "Kaiky Pereira Rodrigues (RM564578)"
  ]
}
```
- Execute → **201 Created**. **Copie o `id`** retornado (GUID) e cole no bloco de notas: será o `<GRUPO_ID>`.
- **SELECT** no Cloud Shell → mostre o novo documento "Equipe DevOps CP06" na coleção `Grupos`.

### 10.3 READ – `GET /api/grupos/{id}`
- Swagger → `GET /api/grupos/{id}` → cole `<GRUPO_ID>` → 200 com o grupo. (`GET /api/grupos` lista todos.)
- Fale: "a leitura pela API bate com o que está no banco".

### 10.4 UPDATE – `PUT /api/grupos/{id}`
- `PUT /api/grupos/{id}` com `<GRUPO_ID>` e corpo (`03-grupos-PUT.json`):
```json
{
  "nome": "Equipe DevOps CP06 - Atualizada",
  "turma": "2TDSPV",
  "integrantes": [
    "Gabriel Costa Solano (RM562325)",
    "Leandro Guarido (RM561760)",
    "Kaiky Pereira Rodrigues (RM564578)"
  ]
}
```
- Execute → 200/204. **SELECT** → mostre o `nome` alterado para "... - Atualizada".

> O DELETE do grupo fica para **depois** da cena 11 (um trabalho aponta para ele; apagar o grupo antes quebraria o relacionamento).

---

## Cena 11 – CRUD da tabela **Trabalhos** (relacionada a Grupos) (≈ 7 min)

### 11.1 CREATE – `POST /api/trabalhos`
Use o `<GRUPO_ID>` da cena 10 no campo `grupoId` (é a chave estrangeira → `Grupos._id`):
```json
{
  "titulo": "Pipeline CI/CD FIAP NEXT",
  "descricao": "Trabalho criado para demonstrar o CRUD da API publicada pela pipeline no Azure.",
  "categoria": "DevOps",
  "linkRepositorio": "https://dev.azure.com/<organizacao>/<projeto>/_git/<repositorio>",
  "linkPitch": "https://youtube.com/watch?v=pitch_devops",
  "grupoId": "<GRUPO_ID>",
  "nota": 8.5,
  "relevancia": 80
}
```
- Execute → **201**. Copie o `id` do trabalho → `<TRABALHO_ID>`.
- **SELECT** → mostre em `Trabalhos` o documento novo com `grupoId` igual ao `_id` do grupo. **Fale:** "aqui está o relacionamento entre as duas coleções".
- (Dica: `nota 8.5` e `relevancia 80` fazem `EhDestaque()` ser verdadeiro, comentário opcional.)

### 11.2 READ – `GET /api/trabalhos/{id}`
- Cole `<TRABALHO_ID>` → 200. Mostre também `GET /api/trabalhos` listando.

### 11.3 UPDATE – `PUT /api/trabalhos/{id}`
Corpo (`05-trabalhos-PUT.json`, **sem** `grupoId`):
```json
{
  "titulo": "Pipeline CI/CD FIAP NEXT - Atualizado",
  "descricao": "Trabalho atualizado via PUT para demonstrar o U do CRUD no banco em nuvem.",
  "categoria": "DevOps",
  "linkRepositorio": "https://dev.azure.com/<organizacao>/<projeto>/_git/<repositorio>",
  "linkPitch": "https://youtube.com/watch?v=pitch_devops",
  "nota": 9.5,
  "relevancia": 90
}
```
- Execute → 200/204. **SELECT** → título "- Atualizado", nota 9.5 e relevância 90.

### 11.4 DELETE – `DELETE /api/trabalhos/{id}`
- `DELETE /api/trabalhos/{id}` com `<TRABALHO_ID>` → 204.
- **SELECT** → o trabalho **não aparece mais** em `Trabalhos`.

### 11.5 DELETE do grupo – `DELETE /api/grupos/{id}`
- Agora sem trabalhos dependentes: `DELETE /api/grupos/{id}` com `<GRUPO_ID>` → 204.
- **SELECT** → "Equipe DevOps CP06" sumiu de `Grupos`.

### Resumo do que o professor precisa ver (confira antes de encerrar)
| # | Operação | Tabela | SELECT depois? |
|---|---|---|---|
| 1 | POST | Grupos | ✔ |
| 2 | GET | Grupos | (API) |
| 3 | PUT | Grupos | ✔ |
| 4 | POST (com `grupoId`) | Trabalhos | ✔ |
| 5 | GET | Trabalhos | (API) |
| 6 | PUT | Trabalhos | ✔ |
| 7 | DELETE | Trabalhos | ✔ |
| 8 | DELETE | Grupos | ✔ |

### Se algo der errado no CRUD
| Sintoma | Causa provável | O que fazer |
|---|---|---|
| 401 Unauthorized | Token ausente/expirado | Refaça o login e o **Authorize** (`Bearer <token>`) |
| 400 Bad Request no POST trabalho | `grupoId` inexistente, nota/relevância fora da faixa ou URL inválida | Confira o `<GRUPO_ID>`; links devem começar com `https://` |
| 404 | Id errado ou recurso já apagado | Copie o id de novo da resposta do POST |
| 500 / timeout | Mongo fora ou connection string errada | Portal → Container instance *Running*? Reveja a variável `MONGO_CONNECTION` e refaça o CD |
| `consultar` demora | `az container exec` abre sessão no container | Aguarde ~10–15 s por consulta (fale algo enquanto roda) |

---

## Cena 12 – Arquivos no Azure Repos (≈ 2 min)
Repos → Files, abra e mostre rapidamente (3–5 s cada):
`azure-pipeline.yml` · `infra/` (`00_variaveis.sh` … `04_consultar-banco.sh`) · `script.sql` · `Dockerfile` · `docker-compose.yml` · `json-crud/` · código-fonte (`FiapNext.Api`, `FiapNext.Domain`, `FiapNext.Tests.Unit`).
**Fale:** "a infraestrutura foi criada por scripts CLI e o banco foi preparado pelo script.sql".

## Cena 13 – Acesso do professor (≈ 1 min)
1. Organization settings → **Users**: mostre `pf0841@fiap.com.br` com **Access level: Basic**.
2. Project settings → **Permissions → Project Administrators → Members**: mostre `pf0841@fiap.com.br` na lista.

## Encerramento (≈ 30 s)
> "Concluímos: Boards, Repos com políticas, CI com testes unitários, CD no App Service, CRUD em duas tabelas validado por SELECT no banco em nuvem e o acesso do professor configurado. Obrigado."

Pare a gravação **só depois** de falar isso.

---

## Depois de gravar
1. Assista pelo menos o começo, o meio e o fim: áudio audível? texto legível? alguma senha visível?
2. YouTube → Enviar vídeo → Visibilidade **Não listado** → qualidade **720p ou mais** (aguarde o processamento HD).
3. Cole o link `https://youtu.be/<id>` no PDF (ver `MODELO_PDF.md`).

## Linha do tempo resumida
| Cena | Conteúdo | Tempo |
|---|---|---|
| 1 | Apresentação | 1 min |
| 2 | Boards (Task Active) | 1 min |
| 3 | Branch + políticas | 2 min |
| 4 | Passo 06 – código | 5 min |
| 5 | PR + fechar Task | 3 min |
| 6 | Passo 07 – CI | 4 min |
| 7 | Passo 07 – CD | 3 min |
| 8 | Portal Azure | 2 min |
| 9 | App na nuvem | 2 min |
| 10 | CRUD Grupos | 6 min |
| 11 | CRUD Trabalhos | 7 min |
| 12 | Arquivos no Repos | 2 min |
| 13 | Acesso do professor | 1 min |
| – | Total | ≈ 39 min |
