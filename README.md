# HTTP Server

Run on port 8080

## Manual run 

```shell
> set -a && source config/.env && set +a
> go run main.go
```

## Docker Compose run 

```shell
> mv docker-compose.yaml.example docker-compose.yaml
> docker-compose up -d --build --remove-orphans
```
