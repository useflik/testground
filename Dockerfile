############################
# STEP 1 build executable binary
# pull official base image
############################
FROM golang:1.17-buster as builder

ARG GITHUB_TOKEN
ARG GITHUB_USER

ENV GITHUB_TOKEN=${GITHUB_TOKEN}
ENV GITHUB_USER=${GITHUB_USER}

# Install dependencies
# Git is required for fetching the dependencies.
# Ca-certificates is required to call HTTPS endpoints.
# tzdata is for timezone info
RUN apt-get update && \
    apt-get install -y git ca-certificates tzdata \
    && update-ca-certificates

# Specify workdir to avoid error $GOPATH/go.mod exists but should not
WORKDIR /app

# Fetch dependencies.
# Using go mod with go > 1.11
# will also be cached if we won't change mod/sum
ENV GO111MODULE=on
COPY go.mod go.sum ./
RUN export GOPROXY=https://proxy.golang.org && go mod download -x 
RUN go mod verify && \
    go mod tidy

# Copy the source code
# Build the binary
COPY . .

# HTTP server binary
RUN CGO_ENABLED=0 \
    GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" \
    -o http_test_server \
    ./main.go

############################
# STEP 2 build a small image
############################

# Dynatrace can't do deep scanning in alpine
FROM debian:buster-slim

# Create user
WORKDIR /app
ENV USER=flik
ENV UID=10001
ENV TZ=Asia/Jakarta

# Add new user, no need to use root user
RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "$UID" \    
    "$USER"

# Copy our static executable
COPY --from=builder --chown=$USER:$USER /app/http_test_server .
COPY --from=builder --chown=$USER:$USER /app/templates templates/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
RUN apt-get update; \
    apt-get upgrade; \ 
    cp /usr/share/zoneinfo/${TZ} /etc/localtime; \
    date;

RUN echo Y || apt-get install curl

# Tell docker how the process PID 1 handle gracefully shutdown
# Signal Interupt for gracefully shutdown echo server
STOPSIGNAL SIGINT

EXPOSE 8080

ENTRYPOINT ["./http_test_server"]
