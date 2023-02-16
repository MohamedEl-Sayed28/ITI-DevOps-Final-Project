# ITI-DevOps-Final-Project

# Deploy backend application on kubernetes eks cluster using CI/CD Jenkins pipeline

## Tools
- Terraform
- Amazon Web Services (AWS)
- Jenkins

## First
- Creating infrastructure using terraform

## Infrastructure commands using in project by terraform

```bash
terraform init 
terraform validate #to make sure there are no syntax errors
terraform plan #to make sure everything will be created correctly
terraform apply #to apply infrastructure on aws cloud provider 
```

## Build jenkins image

Build image for jenkins using Dockerfile by

```bash
  docker build . -f jenkins_with_docker -t mohamedmahmoud94/myjenkins:v1
  docker push mohamedmahmoud94/myjenkins:V1 
```
![image](https://user-images.githubusercontent.com/101838529/219447927-2c31fad5-137b-4999-8a8e-5d57e8b008e2.png)
![image](https://user-images.githubusercontent.com/101838529/219448124-e1e27476-f588-4a6f-8f8c-78bf71753a65.png)
![image](https://user-images.githubusercontent.com/101838529/219448185-cb0241e6-dafc-4340-92e1-db89de6e43a6.png)


Dockerhub jenkins image repository: https://hub.docker.com/repository/docker/mohamedmahmoud94/myjenkins/general


# Project requirements

## Use separate namespace for Jenkins's deployment and application's deployment 
```bash
kubectl create namespace Jenkins
kubectl create namespace app
```

