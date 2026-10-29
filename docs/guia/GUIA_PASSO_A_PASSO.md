# Guia passo a passo – 3º Checkpoint (Pipelines CI/CD) – FIAP NEXT API

Projeto migrado: **FiapNext API** (.NET 10, Minimal API) com **MongoDB** (NoSQL, relação `Trabalhos.grupoId → Grupos._id`).
Destino: **Azure App Service (Linux)** + banco **MongoDB em container no ACI**. Tudo conforme as apostilas
(Semana 19 – Pipelines .NET/YAML, Aula 12 – ACI, Aulas 17/18 – Azure DevOps/Repos/Boards, Aula 08 – Azure CLI).

> Tudo o que está em `Entrega/repositorio/` é o conteúdo que vai para o **Azure Repos**.
> Esta pasta `guia/` fica só com você (não vai para o repositório).

## Visão geral da ordem

| Ordem | O que fazer | Onde |
|---|---|---|
| A | Criar infraestrutura (RG, Mongo no ACI, Web App) | Cloud Shell |
| B | Projeto + Boards + Repos + políticas (passos 01–03 do PDF) | Azure DevOps |
| C | Service Connection + Pipeline (passos 04–05) | Azure DevOps |
| D | Alteração de código via Task/Branch/PR (passo 06) | Azure DevOps |
| E | Pipelines automáticas + evidências (passo 07) | Azure DevOps / Portal |
| F | Acesso do professor, vídeo e PDF | – |

---

## A) Infraestrutura via script (antes de tudo)

1. Abra o **Cloud Shell (Bash)** no portal Azure (`portal.azure.com`).
2. Verifique a assinatura (Aula 08):
   ```bash
   az account show
   az account list -o table
   az account set --subscription "nome-da-assinatura-correta"
   ```
3. Envie o arquivo `Entrega/infra-cloudshell.zip` (Cloud Shell → *Manage files → Upload*) e extraia:
   ```bash
   unzip infra-cloudshell.zip && cd infra
   ```
4. Edite `00_variaveis.sh` se precisar (RM, `LOCATION` conforme sua Policy – ver apostila *Azure Policy Regiões*, e `RUNTIME`).
   Antes, confirme o runtime .NET 10 disponível: `az webapp list-runtimes --os-type linux | grep -i dotnetcore`.
5. Execute **na ordem**:
   ```bash
   chmod +x *.sh
   ./01_criar-grupo-recursos.sh
   ./02_criar-banco-mongo-aci.sh      # gera infra/.segredos.env (senha do Mongo e chave JWT)
   ./03_criar-webapp.sh
   ./04_consultar-banco.sh aplicar    # aplica o script.sql (coleções, validação, índices)
   ```
6. Anote para a Pipeline: o conteúdo de `.segredos.env` (`cat .segredos.env`) e o FQDN do Mongo
   (impresso pelo script 02). A connection string é:
   `mongodb://fiapnext:<MONGO_PASSWORD>@<FQDN>:27017/?authSource=admin`
7. O banco só ganha dados (usuários `admin@fiap.com.br` / `Admin@123`, grupo e trabalho de exemplo) quando a **API sobe pela primeira vez** (seed no `Program.cs`).

⚠️ O Mongo no ACI **não tem volume**: se o container reiniciar, os dados somem (o seed recria o básico). Para o laboratório é suficiente.
⚠️ O container fica com a porta 27017 pública (protegida por usuário/senha). Apague o laboratório após a correção (`99_limpar-laboratorio.sh`).

---

## B) Passos 01, 02 e 03 do PDF

### 01) Novo projeto (Git + Agile/Scrum)
`dev.azure.com/<sua-organizacao>` → **New project**:
- Nome: `FiapNext-Pipelines` · Visibility: **Private**
- *Advanced* → **Version control: Git** · **Work item process: Agile** (é nele que a Task tem o estado **Active**, exigido no passo 02).

### 02) Azure Boards
Boards → Work items → **New Work Item → Task**
- Title: `Implementar FIAP NEXT API (.NET + MongoDB) no Azure DevOps`
- **Assigned to:** você · **State: Active** → Save.
Anote o número da Task (ex.: `#12`).

### 03) Azure Repos
1. **Importar o código** (o projeto + os arquivos novos de `Entrega/repositorio`). Como o repositório precisa conter os scripts/YAML/Dockerfile que criei, faça o push do conteúdo local:
   - Repos → *Files* → copie a URL de clone (HTTPS) → **Generate Git Credentials** (guarde usuário/senha do Git).
   ```bash
   cd "Entrega/repositorio"
   git init -b main
   git add .
   git commit -m "Importação inicial do projeto FIAP NEXT"
   git remote add origin <URL-DO-REPOS>
   git push -u origin main
   ```
   (Se preferir o botão *Import repository* da apostila, importe do GitHub e depois suba os arquivos novos; o resultado é o mesmo.)
2. **Criar a branch a partir da Task**: abra a Task → seção **Development → Create a branch** → nome sugerido `feature/destaque-trabalho`, base `main`.
3. **Proteger a `main`**: Repos → Branches → `main` → **⋯ → Branch policies**:
   - ☑ **Require a minimum number of reviewers** = 1 e **☑ Allow requestors to approve their own changes** (necessário, pois você mesmo aprova a PR).
   - ☑ **Check for linked work items → Required**.
   - ☑ **Automatic reviewers → Add** → seu usuário (RM) · *Required*.
   (Reviewer extra: se o professor da Aula 18 exigir, convide um colega em *Organization settings → Users*.)

---

## C) Passos 04 e 05 – Pipelines

### Service Connection (apostila Semana 19-03)
Project settings → **Service connections → New → Azure Resource Manager** (Service principal automatic):
Scope level **Subscription** → sua assinatura → Resource group (vazio ou o `rg-fiapnext-<RM>`) → nome **`MyAzureSubscription`** → ☑ *Grant access permission to all pipelines*.

### Criar a Pipeline (YAML – modelo da apostila)
Pipelines → **Create Pipeline → Azure Repos Git → seu repositório → Existing Azure Pipelines YAML file** → branch `main`, path **`/azure-pipeline.yml`**.
(Na apostila: *Starter pipeline* e colar o conteúdo; o resultado é o mesmo.)

Antes de rodar, **Variables → New variable** (marque **Keep this value secret** nas indicadas):

| Variável | Valor | Secreta |
|---|---|---|
| `NOME_WEBAPP` | `fiapnext-api-561760` (nome do Web App criado) | não |
| `ASPNETCORE_ENVIRONMENT` | `Production` | não |
| `MONGO_DATABASE` | `FiapNextDb` | não |
| `MONGO_CONNECTION` | `mongodb://fiapnext:<senha>@<fqdn>:27017/?authSource=admin` | **sim** |
| `JWT_SECRET` | valor de `JWT_SECRET` do `.segredos.env` | **sim** |

### Passo 04 – CI manual
**Run pipeline** (branch `main`). Na 1ª execução clique em **Permit** (Service Connection). O stage **CI – Build e Testes** faz restore → build → **testes unitários** → publish → artefato.
Verifique: aba **Tests** da execução (50 testes passando) e os logs de cada task.

### Passo 05 – CD manual
O stage **CD – Release no App Service** consome o artefato `app` e faz deploy no Web App. Para testar o CD isoladamente, abra uma execução concluída → **Rerun stage** no CD (ou *Run pipeline* de novo).
Validação: `https://fiapnext-api-561760.azurewebsites.net/` (Swagger na raiz) e `/health`.

> Se o professor exigir a interface clássica de *Release* (Create Release), diga-me que eu escrevo o roteiro no Classic Editor; para esta entrega usamos YAML (permitido no PDF: “Utilizando a criação da Pipeline por arquivo YAML: o arquivo azure-pipeline.yml”).

---

## D) Passo 06 – Alteração de código ponta a ponta

Tudo na **branch criada pela Task** (`feature/destaque-trabalho`), direto no Repos (Files → editar → Commit), **não** no README:

1. `FiapNext.Domain/Entities/Trabalho.cs` – adicione antes de `private static void ValidarUrl`:
   ```csharp
       // Regra de negócio: trabalho em destaque no festival (nota >= 8 e relevância >= 70)
       public bool EhDestaque() => Nota >= 8.0m && Relevancia >= 70.0m;
   ```
2. `FiapNext.Tests.Unit/Domain/` → **New file** `TrabalhoDestaqueTests.cs` com o conteúdo de `guia/alteracao-codigo/TrabalhoDestaqueTests.cs` (4 testes novos → **54** testes no CI).
3. `FiapNext.Api/Program.cs` – antes de `app.MapAuthEndpoints();` (rota visível na nuvem, igual à apostila):
   ```csharp
   // Rota incluída - API somente GET em /wellcome
   app.MapGet("/wellcome", () => Results.Text("Rota adicionada"))
      .WithName("Wellcome")
      .WithTags("Health")
      .Produces<string>(StatusCodes.Status200OK);
   ```
4. Em **cada commit**, na mensagem inclua o vínculo com a Task: `Adiciona regra de trabalho em destaque #12` (o `#12` = número da sua Task).
5. **Pull requests → New** (`feature/destaque-trabalho` → `main`): título/descrição, o reviewer padrão já entra, confirme o **Work item linkado**.
6. Aprove a PR você mesmo (**Approve**) e clique **Complete**:
   - Merge type: *Merge (no fast-forward)* ou *Squash* · 
   - **☐ Delete feature branch after merging** → **DESMARCADO** (o PDF pede para não deletar).
   - **☑ Complete associated work items after merging** (fecha a Task).

(Eu testei esta alteração numa cópia: 54 testes passando e a API compila.)

---

## E) Passo 07 – Execução das Pipelines + evidências

1. O merge na `main` dispara o **CI automaticamente** e, ao terminar, o **CD** (mesmo YAML, stage dependente). Acompanhe em Pipelines → execução.
2. Mostre o **log de cada task** (CI e CD) e a aba **Tests** (54 testes, incluindo os 4 novos `TrabalhoDestaqueTests`).
3. Teste a nuvem: `https://<webapp>.azurewebsites.net/wellcome` e o Swagger.
4. **Portal Azure**: Resource group `rg-fiapnext-<RM>` com *Container instance*, *App Service plan* e *App Service* (criados pelos scripts).
5. **CRUD nas duas tabelas** (Grupos e Trabalhos) com os JSONs de `json-crud/`: após **cada** operação rode `./infra/04_consultar-banco.sh consultar` no Cloud Shell (é o “SELECT” direto no banco em nuvem).
   Sequência sugerida: login → POST grupo → SELECT → PUT grupo → SELECT → POST trabalho (com `grupoId` do grupo) → SELECT → PUT trabalho → SELECT → DELETE trabalho → SELECT → DELETE grupo → SELECT.

---

## F) Fechamento

- **Professor**: *Organization settings → Users → Add users* → `pf0841@fiap.com.br` · Access level **Basic** · adicionar ao projeto. Depois *Project settings → Permissions → Project Administrators → Members → Add* o mesmo usuário (e ele fica também como Contributor via Project Valid Users). Se o convite externo falhar, habilite *Organization settings → Policies → External guest access*.
- **Vídeo** (YouTube, ≥720p, sem cortes): siga `ROTEIRO_VIDEO.md`.
- **PDF** `<nomeGrupo>_pipelines.pdf`: siga `MODELO_PDF.md`. Upload no Teams **somente pelo representante**.
- Confira o `CHECKLIST_PENALIDADES.md`.

## Pontos de atenção (riscos conhecidos)

- **Agentes hospedados**: organizações novas podem não ter paralelismo gratuito (erro “No hosted parallelism has been purchased or granted”). Peça em `https://aka.ms/azpipelines-parallelism-request` ou use a organização do laboratório da FIAP.
- **Runtime .NET 10 no App Service Linux**: não consegui validar `DOTNETCORE:10.0` sem o `az`; o script 03 lista os runtimes antes de criar. Se não existir, o projeto (net10.0) não roda no App Service; a alternativa é publicar via ACR/ACI (Dockerfile já incluso).
- **Segredo no repositório**: `appsettings.json` ainda contém a chave JWT de desenvolvimento (já era assim no CP05); na nuvem ela é sobrescrita pela variável secreta `Jwt__SecretKey`.
- Primeira requisição ao Web App pode levar alguns segundos (cold start).
