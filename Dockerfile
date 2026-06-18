# Use the official ASP.NET Core runtime as a base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

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
WORKDIR "/src/AIStudyHub.API"
RUN dotnet build "AIStudyHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "AIStudyHub.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Build the final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create a folder for uploads and ensure wwwroot exists
RUN mkdir -p /app/wwwroot/uploads/documents

ENTRYPOINT ["dotnet", "AIStudyHub.API.dll"]
