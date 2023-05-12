# Simple Bank

This repository contains the codes of the [Backend Master Class](https://bit.ly/backendmaster).

![Backend master class](backend-master.png)

# Deploy and test locally
Run 

`docker run --name postgres12 -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine` 

to create postgres container, the environment variables are used for connect this database. To test if it's successful, we can run 

`docker exec -it postgres12 psql -U root` 

enter the container and run `select now();` to see the current time.

Then open tablePlus to connect this local postgres database, using the environment variables above:
```
Name=postgres12
Host=127.0.0.1
Port=5432
User=root
Password=secret
Database=root
```

Now we got an empty database, to create tables, run `make migrate migrateupLocal` then F5 fresh tablePlus and we are able to see all the tables.
To run server, run `make server` and go to runAPI, create a new POST, set URL as http://localhost:8080/users and choose json for body:
```
{
    "username":"alice1",
    "password":"orange",
    "full_name":"Alice",
    "email":"alice1@gmail.com"
}
```
Then we are able to see a user created in tablePlus.

# Build image and test it locally:
```
build -t simplebank .
network create bank-network
docker network connect bank-network postgres12
docker run --name simplebank --network bank-network -p 8080:8080 -e GIN_MODE=release -e DB_SOURCE="postgresql://root:secret@postgres/simple_bank?sslmode=disable" simplebank:latest
```
Now, the server is running. Since it's release mode, there will be no text before we send a request.
