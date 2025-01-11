# Build stage for API
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS api-build
WORKDIR /src
COPY ["Api/Api.csproj", "Api/"]
RUN dotnet restore "Api/Api.csproj"
COPY ["Api/", "Api/"]
WORKDIR "/src/Api"
RUN dotnet build "Api.csproj" -c Release -o /app/build
RUN dotnet publish "Api.csproj" -c Release -o /app/publish

# Build stage for Worker
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS worker-build
WORKDIR /src
COPY ["Worker/Worker.csproj", "Worker/"]
RUN dotnet restore "Worker/Worker.csproj"
COPY ["Worker/", "Worker/"]
WORKDIR "/src/Worker"
RUN dotnet build "Worker.csproj" -c Release -o /app/build
RUN dotnet publish "Worker.csproj" -c Release -o /app/publish

# Runtime stage for API
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS api
WORKDIR /app
COPY --from=api-build /app/publish .
ENTRYPOINT ["dotnet", "Api.dll"]

# Runtime stage for Worker
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS worker
WORKDIR /app
COPY --from=worker-build /app/publish .
ENTRYPOINT ["dotnet", "Worker.dll"] 
