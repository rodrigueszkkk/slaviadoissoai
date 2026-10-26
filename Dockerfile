# ---------- Estágio de build ----------
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY FiapNext.slnx ./
COPY FiapNext.Domain/FiapNext.Domain.csproj FiapNext.Domain/
COPY FiapNext.Application/FiapNext.Application.csproj FiapNext.Application/
COPY FiapNext.Infrastructure/FiapNext.Infrastructure.csproj FiapNext.Infrastructure/
COPY FiapNext.Api/FiapNext.Api.csproj FiapNext.Api/
RUN dotnet restore FiapNext.Api/FiapNext.Api.csproj

COPY FiapNext.Domain/ FiapNext.Domain/
COPY FiapNext.Application/ FiapNext.Application/
COPY FiapNext.Infrastructure/ FiapNext.Infrastructure/
COPY FiapNext.Api/ FiapNext.Api/
RUN dotnet publish FiapNext.Api/FiapNext.Api.csproj -c Release -o /app/publish --no-restore

# ---------- Estágio de execução ----------
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "FiapNext.Api.dll"]
