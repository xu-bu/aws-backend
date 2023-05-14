# notice that do not add comment with code in single same line
# divide it into 2 stages to reduce the size of image
# Build stage
# use "AS builder" to point out it's build stage
FROM golang:1.16-alpine3.13 AS builder 
WORKDIR /app
COPY . .
RUN go build -o main main.go
install curl
RUN apk --no-cache add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.14.1/migrate.linux-amd64.tar.gz | tar xvz

# "FROM alpine:3.13" to point out it's Run stage
FROM alpine:3.13
WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/migrate.linux-amd64 ./migrate
COPY start.sh .
COPY wait-for.sh .
RUN chmod +x /app/start.sh
RUN chmod +x /app/wait-for.sh
COPY db/migration ./migration

EXPOSE 8080

ENTRYPOINT [ "/app/start.sh" ]
CMD [ "/app/main" ]
# CMD ["/bin/sh", "-c", "while true; do sleep 1; done"]




