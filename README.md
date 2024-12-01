![Build Status](https://github.com/felpsey/laravel-azure-ci-cd-example/actions/workflows/build.yml/badge.svg)

This project aims to serve as an example for implementing Continuous Integration and Continuous Deployment (CI/CD) for a Laravel application using Azure.

There are three methods of deploying this application:

1. Docker
2. Azure App Service
3. Kubernetes

# Deployment

Each method of deployment represents an isolated environment and are not dependent on each other.

## Docker

Docker deployment is recommended for local development, as an alterantive to Laravel Sail. This method simulates the deployment of the Docker image and is useful for image debugging.

### Prerequities

- Docker Engine or Docker Desktop
- Docker Buildx
- AMD64, or a platform that can emulate AM64 such as macOS Rosetta
- Internet Access
- MySQL database

### Instructions

1. Clone the GitHub repository

2. Build and run the image, ensure that the directory context is set to the root of the repository

You may either build or build and run the image:

```bash
# Build
docker build -t laravel-azure-ci-cd-example:latest -f .docker/app.Dockerfile .
```

```bash
# Build and Run
- Build and Run: `docker compose -f .docker/docker-compose.yml up --build`
```

3. Access the application at http://localhost:80

4. Connect to the running container instance and copy the environment variable template file

```bash
cd /var/www/html/ &&  cp .env.example .env
```

5. Edit the environment variable file and populate the database connection details

```bash
nano .env
```