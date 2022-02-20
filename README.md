# HTTP Server

Run on port 8080

```shell
# create .env file
> copy config/.env.example config/.env
```


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
