# Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Copy DataEntities project and build it
WORKDIR /src
COPY ["DataEntities/DataEntities.csproj", "DataEntities/"]
RUN dotnet restore "DataEntities/DataEntities.csproj"
COPY "DataEntities/" "DataEntities/"
WORKDIR "/src/DataEntities"
RUN dotnet build "DataEntities.csproj" -c Release -o /app/build

# Copy Store project and build it
WORKDIR /src
COPY ["Store/Store.csproj", "Store/"]
RUN dotnet restore "Store/Store.csproj"
COPY "Store/" "Store/"
WORKDIR "/src/Store"
RUN dotnet build "Store.csproj" -c Release -o /app/build

# Publish Store project
RUN dotnet publish "Store.csproj" -c Release -o /app/publish

# Use the ASP.NET runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Copy the output from the build stage
COPY --from=build /app/publish .

# Ensure the correct entry point
ENTRYPOINT ["dotnet", "Store.dll"]
