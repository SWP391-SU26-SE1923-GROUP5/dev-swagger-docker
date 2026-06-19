# Use the official ASP.NET Core runtime as a base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

# Expose the application port
EXPOSE 8080

# Environment variables for production
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Use the SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy project files and restore dependencies
COPY ["AIStudyHub.API/AIStudyHub.API.csproj", "AIStudyHub.API/"]
COPY ["AIStudyHub.Business/AIStudyHub.Business.csproj", "AIStudyHub.Business/"]
COPY ["AIStudyHub.Data/AIStudyHub.Data.csproj", "AIStudyHub.Data/"]
RUN dotnet restore "AIStudyHub.API/AIStudyHub.API.csproj"

# Copy the remaining source code
COPY . .

# Build the application
WORKDIR "/src/AIStudyHub.API"
RUN dotnet build "AIStudyHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "AIStudyHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Build the final image
FROM base AS final
WORKDIR /app

# Create non-root user for security
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app

# Copy published output
COPY --from=publish /app/publish .

# Create directories for logs and uploads with proper permissions
RUN mkdir -p /app/logs /app/wwwroot/uploads/documents && \
    chown -R appuser /app/logs /app/wwwroot

USER appuser

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "AIStudyHub.API.dll"]
