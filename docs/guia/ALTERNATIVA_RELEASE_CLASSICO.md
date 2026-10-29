# Alternativa: CI (Build) clássico + Release clássico (Create Release)

Segue a apostila *Semana 19-03* (parte “Classic Editor”). Use **no lugar** da pipeline YAML dos passos 04/05 do guia
(não crie as duas, ou o deploy rodará duas vezes). O `azure-pipeline.yml` continua no Repos como arquivo da entrega,
mas **não** crie a pipeline a partir dele.

Pré-requisitos iguais: infra criada (Cloud Shell), Service Connection `MyAzureSubscription`, Task/branch/políticas prontas.
Se o menu **Pipelines → Releases** não aparecer: *Project settings → Pipelines → Settings* e desative “Disable creation of classic release pipelines”.

---

## Passo 04 – Pipeline de Build (CI) – Classic Editor

1. Pipelines → **Create Pipeline → Use the classic editor** → Azure Repos Git → seu projeto/repositório/branch `main` → Continue.
2. Template: **ASP.NET Core** → Apply.
3. **Pipeline**: nome `FiapNext-CI` · Agent pool *Azure Pipelines* · Agent specification `ubuntu-latest`.
4. **Agent job 1**: renomeie para `Build and Test`.
5. Tasks (ajuste cada uma, nesta ordem):

| Task | Ajustes |
|---|---|
| **Restore** | *Path to project(s)*: `FiapNext.Api/FiapNext.Api.csproj` |
| **Build** | *Projects*: `FiapNext.Api/FiapNext.Api.csproj` · Arguments: `--configuration Release` |
| **Test** | *Projects*: `FiapNext.Tests.Unit/FiapNext.Tests.Unit.csproj` · Arguments: `--configuration Release` · **Test run title**: `Testes Unitarios FiapNext` · ☑ *Publish test results* (é o que alimenta a aba Tests) |
| **Publish** | ☐ *Publish web projects* · *Projects*: `FiapNext.Api/FiapNext.Api.csproj` · Arguments: `--configuration Release --output $(Build.ArtifactStagingDirectory)` · ☑ *Zip published projects* |
| **Publish Artifact** | *Path to publish*: `$(Build.ArtifactStagingDirectory)` · *Artifact name*: `app` · Publish location *Azure Pipelines* |

   Se faltar o SDK 10 no agente, adicione antes de Restore a task **Use .NET Core** (`UseDotNet`) → *Package to install*: SDK · Version `10.0.x`.
6. **Triggers** → ☑ *Enable continuous integration* · Branch filter *Include* `main`.
7. **Save & queue** → rode manualmente (passo 04 do PDF). Confira a aba **Tests** e os logs de cada task.

## Passo 05 – Pipeline de Release (CD)

1. Pipelines → **Releases → New → New release pipeline**.
2. Template: **Azure App Service deployment** → Apply. Renomeie a pipeline para `FiapNext-CD` e o stage para `Deploy Dev`.
3. **Add an artifact**: *Source type* **Build** · Project · *Source (build pipeline)* `FiapNext-CI` · *Default version* **Latest** · Source alias `_FiapNext-CI`.
4. Clique no raio ⚡ do artefato → **Continuous deployment trigger = Enabled** (Build dispara Release automaticamente — exigido no passo 07).
5. No stage, clique em **1 job, 1 task**:
   - *Azure subscription*: `MyAzureSubscription` → Authorize.
   - *App type*: **Web App on Linux** · *App Service name*: `fiapnext-api-561760` (o que o script 03 criou).
   - Agent job: *Agent pool* Azure Pipelines · *Agent specification* `ubuntu-latest`.
   - Task **Deploy Azure App Service**: *Package or folder*: `$(System.DefaultWorkingDirectory)/**/*.zip`.
   - Em *Application and Configuration Settings → App settings*, cole (formato do slide 38 da apostila):
     ```
     -ASPNETCORE_ENVIRONMENT $(ASPNETCORE_ENVIRONMENT) -MongoDb__ConnectionString "$(MONGO_CONNECTION)" -MongoDb__DatabaseName $(MONGO_DATABASE) -Jwt__SecretKey "$(JWT_SECRET)"
     ```
6. Aba **Variables** da Release:

| Nome | Valor | Cadeado |
|---|---|---|
| `ASPNETCORE_ENVIRONMENT` | `Production` | não |
| `MONGO_DATABASE` | `FiapNextDb` | não |
| `MONGO_CONNECTION` | `mongodb://fiapnext:<senha>@<fqdn>:27017/?authSource=admin` | **sim** |
| `JWT_SECRET` | valor do `.segredos.env` | **sim** |

7. **Save**. Teste manual: **Create release → Create** → acompanhe em *Releases* → clique no stage → **Logs**.
8. Valide: `https://fiapnext-api-561760.azurewebsites.net/` e `/health`.

## Passo 07 com o modelo clássico
- O merge da PR na `main` dispara `FiapNext-CI` (CI habilitado) e, ao terminar, `FiapNext-CD` (Continuous deployment). Mostre os logs das duas e a aba **Tests** do build.
- No vídeo, mostre também a tela do artefato com o raio habilitado.

## Ajustes na entrega
- No PDF/vídeo, diga que o YAML `azure-pipeline.yml` está no Repos como definição equivalente, e que a execução demonstrada foi pelo Classic Editor + Release.
- Se quiser entregar **só** um modelo, escolha um e cite no vídeo; o professor pede “YAML” apenas se a pipeline for criada por arquivo.
