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
If wanna change Dockerfile and test it again, you need to delete simplebank container and run the code above again.

# Create ECR and user on AWS
1. Go to AWS, create a free-tier eligible instance and a Amazon ECR named simplebank. Go to deploy.yml, change aws-region and add secrets in github. 
2. Go to IAM in AWS and create a new user named github-ci and add it to a new group named deployment which uses AmazonContainerRegistryPublicFullAccess strategy.
3. Enter the overview tab of this user. Open the Security credentials tab, and then choose Create access key. Paste access key ID and secret to create a AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in github actions.


# Create and connect a production DB on AWS RDS
Install goland migrate and then follow the tutorial: `https://www.youtube.com/watch?v=0EaG3T4Q5fQ`. You may encounter a failure that migrate is conflicted with nvm's migrate, just go to environment variables and change the path of golang migrate upon nvm's.
Finally, change the DB_SOURCE in Makefile and now we can run 
```
docker build -t simplebank .
docker run --name simplebank -p 8080:8080 -e GIN_MODE=release 
```
to test it (since now we use the remote postgres and its addres is already declared in app.env, we don't need to specify it by -e DB_SOURCE=XXXX). It's supposed to see a new record in users table of remote Postgres database when send a create user request.

# Use ECR image locally
After push, github will push image to ECR. Copy its URI to get [ECR image name].
## Auth
```
docker login
aws ecr get-login-password | docker login --username AWS --password-stdin 889406091633.dkr.ecr.eu-west-2.amazonaws.com/simplebank
```
Notice that the token could be expired, then we need to auth again.
## Test ECR image
```
docker run --name simplebank -p 8080:8080 -e GIN_MODE=release --env-file=./app.env --env-file=./app.env [ECR URI]
``` 

# Deploy to kubernetes cluster

- [Install nginx ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/#aws):

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.48.1/deploy/static/provider/aws/deploy.yaml
    ```

- [Install cert-manager](https://cert-manager.io/docs/installation/kubernetes/):

    ```bash
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.4.0/cert-manager.yaml
    ```

# Simple bank service

The service that we’re going to build is a simple bank. It will provide APIs for the frontend to do following things:

1. Create and manage bank accounts, which are composed of owner’s name, balance, and currency.
2. Record all balance changes to each of the account. So every time some money is added to or subtracted from the account, an account entry record will be created.
3. Perform a money transfer between 2 accounts. This should happen within a transaction, so that either both accounts’ balance are updated successfully or none of them are.

# Reference
Fork repository：https://github.com/xu-bu/simplebank-Fork
Tutorial video: https://www.youtube.com/playlist?list=PLy_6D98if3ULEtXtNSY_2qN21VCKgoQAE