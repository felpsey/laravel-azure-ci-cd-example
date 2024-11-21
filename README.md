`docker build -t laravel-azure-ci-cd-example:latest -f .docker/app.Dockerfile .`

`docker compose -f .docker/docker-compose.yml up --build`