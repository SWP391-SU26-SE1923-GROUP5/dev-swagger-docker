FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Development

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["AIStudyHub.API/AIStudyHub.API.csproj", "AIStudyHub.API/"]
COPY ["AIStudyHub.Business/AIStudyHub.Business.csproj", "AIStudyHub.Business/"]
COPY ["AIStudyHub.Data/AIStudyHub.Data.csproj", "AIStudyHub.Data/"]
RUN dotnet restore "AIStudyHub.API/AIStudyHub.API.csproj"

COPY . .

WORKDIR "/src/AIStudyHub.API"
RUN dotnet build "AIStudyHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "AIStudyHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app

COPY --from=publish /app/publish .

RUN mkdir -p /app/logs /app/wwwroot/uploads/documents && \
    chown -R appuser /app/logs /app/wwwroot

USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["sh", "-c", "dotnet AIStudyHub.API.dll --migrate && dotnet AIStudyHub.API.dll"]
