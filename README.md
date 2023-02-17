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
  docker build . -f jenkins_with_docker -t myjenkins:v1
  docker push mohamedmahmoud94/myjenkins:V2 
```
![image](https://user-images.githubusercontent.com/101838529/219447927-2c31fad5-137b-4999-8a8e-5d57e8b008e2.png)
![image](https://user-images.githubusercontent.com/101838529/219448124-e1e27476-f588-4a6f-8f8c-78bf71753a65.png)
![image](https://user-images.githubusercontent.com/101838529/219448185-cb0241e6-dafc-4340-92e1-db89de6e43a6.png)


Dockerhub jenkins image repository: https://hub.docker.com/repository/docker/mohamedmahmoud94/myjenkins/general


## connect to eks cluster
```bash
aws eks --region us-west-1 update-kubeconfig --name eks --profile default
```
![image](https://user-images.githubusercontent.com/101838529/219521365-11f7a49e-a36a-44fe-9bef-88f261aa5ec6.png)

## Setup a Cloud Storage to use it 
```bash
# deploy EFS storage driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# get VPC ID
aws eks describe-cluster --name ITI-Final_Project-cluster --query "cluster.resourcesVpcConfig.vpcId" --output text
# Get CIDR range
aws ec2 describe-vpcs --vpc-ids vpc-00a5b7e9c7db79cff --query "Vpcs[].CidrBlock" --output text
# security for our instances to access file storage
aws ec2 create-security-group --description efs-test-sg --group-name efs-sg --vpc-id vpc-00a5b7e9c7db79cff
aws ec2 authorize-security-group-ingress --group-id sg-05084d2a71d6b9eae  --protocol tcp --port 2049 --cidr 10.0.0.0/16

# create storage
aws efs create-file-system --creation-token eks-efs

# create mount point 
aws efs create-mount-target --file-system-id fs-08d4000327efc8985 --subnet-id subnet-0a8fa8e0f382ff229 --security-group sg-05084d2a71d6b9eae

# grab our volume handle to update our PV YAML
aws efs describe-file-systems --query "FileSystems[*].FileSystemId" --output text
```
![image](https://user-images.githubusercontent.com/101838529/219523284-4008468f-8057-412e-9f97-e8cd3699e7d9.png)
![image](https://user-images.githubusercontent.com/101838529/219523484-3e0c6c3f-011d-4f87-8851-67a254ca636e.png)
![image](https://user-images.githubusercontent.com/101838529/219523699-91f0905c-73e7-428a-b678-2bb2e6b9c236.png)
![image](https://user-images.githubusercontent.com/101838529/219524270-9400ab56-d768-4a9b-b945-73a7874de5d3.png)
![image](https://user-images.githubusercontent.com/101838529/219524766-cc5b0df1-0284-4bde-8e55-840f770d8e2d.png)
![image](https://user-images.githubusercontent.com/101838529/219524960-4849772b-1811-49ba-aba8-569f365593c7.png)
![image](https://user-images.githubusercontent.com/101838529/219526362-100a0d60-775c-465d-9b9f-7159c9c61c57.png)
![image](https://user-images.githubusercontent.com/101838529/219526465-8409ef93-957e-45df-894b-cefe37cc759e.png)


# Project requirements

## Use separate namespace for Jenkins's deployment and application's deployment 
```bash
kubectl create namespace jenkins
kubectl create namespace app
```
![image](https://user-images.githubusercontent.com/101838529/219526903-3490ea12-8b84-4020-8ec7-cc2565379c5e.png)

## Setup a storage for Jenkins
```bash
kubectl get storageclass
```
![image](https://user-images.githubusercontent.com/101838529/219527910-7c73db75-968e-4011-8b2f-04adc5faa607.png)

```bash
# create volume
kubectl apply -f Jen.pv.yaml 
kubectl get pv
```
![image](https://user-images.githubusercontent.com/101838529/219528252-3964ef91-b550-4743-9c26-e330c8329e18.png)

```bash
# create volume claim
kubectl apply -n jenkins -f Jen.pvc.yaml
kubectl -n jenkins get pvc
```
![image](https://user-images.githubusercontent.com/101838529/219528653-c1f0c108-e673-47c8-8e51-300de3547e09.png)

## This step to deploy Jenkins
```bash
# rbac
kubectl apply -n jenkins -f Jen.rbac.yaml 

kubectl apply -n jenkins -f deployment.yaml

kubectl -n jenkins get pods
```
![image](https://user-images.githubusercontent.com/101838529/219534060-9c994f26-a6fb-4735-9d04-9634b2991ddb.png)

## Expose an external url 
```bash
kubectl get all -n jenkins 
```
![image](https://user-images.githubusercontent.com/101838529/219534644-e78f2fdc-a9b4-48a3-9cb2-a0bbea1b7447.png)

## Jenkins run successfuly on the browser
![Screenshot from 2023-02-17 04-34-05](https://user-images.githubusercontent.com/101838529/219535166-49b00759-bf75-4a45-b959-bede6564dd48.png)

## Get Jenkins Password to login 
```bash
kubectl -n jenkins exec -it pod/jenkins-f5899f657-8l97p cat /var/jenkins_home/secrets/initialAdminPassword
```
![image](https://user-images.githubusercontent.com/101838529/219536600-0241fe5d-4b7e-4549-8c5a-b75ed419c7ee.png)
## Install Plugins for Jenkins
![image](https://user-images.githubusercontent.com/101838529/219536819-b6524565-b90c-4654-8d92-985bafd17021.png)
## Create Admin user for Jenkins
![image](https://user-images.githubusercontent.com/101838529/219537272-994739f3-ae74-4768-987d-6ac0db1d41ab.png)


## Create service account to allow any Kubernetes user to have admin access
```bash
kubectl create clusterrolebinding serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts
```
![image](https://user-images.githubusercontent.com/101838529/219553546-38a9cc88-124d-4500-91d8-dec0fb2cfcdd.png)

## Creating CI/CD Pipeline
```
dockerhub & github Credentials
```
![image](https://user-images.githubusercontent.com/101838529/219539917-1dadb675-21fd-436d-a08e-8eaca641731c.png)
![image](https://user-images.githubusercontent.com/101838529/219540081-2ff6d7d0-0399-4c30-b551-70d2024f8f92.png)
![image](https://user-images.githubusercontent.com/101838529/219540928-f1997a70-62fa-4a4f-9958-4fbfc863df8d.png)
![image](https://user-images.githubusercontent.com/101838529/219553885-258e01de-e13a-457b-99a3-27c06568738c.png)
![image](https://user-images.githubusercontent.com/101838529/219553906-2f8a5db5-fc02-49a3-a592-d1ce3c7c2bec.png)
![image](https://user-images.githubusercontent.com/101838529/219553952-9fc051fe-5d25-4133-b87a-08782e5c557f.png)
![image](https://user-images.githubusercontent.com/101838529/219553972-08341564-9ce0-4064-ba22-1b2ea124d4ae.png)
![image](https://user-images.githubusercontent.com/101838529/219553990-a7f6687c-3038-422a-ba8f-0167aaff2b2a.png)
![image](https://user-images.githubusercontent.com/101838529/219554059-f7c79d4e-48b7-42a0-a5db-1f59ceed998a.png)

## kubectl -n app get all
![image](https://user-images.githubusercontent.com/101838529/219554647-9f7b59d4-3019-4e28-ad2e-be21c6f40583.png)
![image](https://user-images.githubusercontent.com/101838529/219554329-23ca96da-16a1-4e9e-b09e-7d0de8fdacd8.png)

## Jenkins exposed externaly
http://aec83d4e1b34948d683c82d1cb4f8ea0-897536538.us-west-1.elb.amazonaws.com/

![image](https://user-images.githubusercontent.com/101838529/219554420-a1605318-bd20-4b22-a1e4-43c90d97327a.png)


## Webapp exposed externaly
a05ece7179c4a49989411339242ccba4-162093534.us-west-1.elb.amazonaws.com

![image](https://user-images.githubusercontent.com/101838529/219554329-23ca96da-16a1-4e9e-b09e-7d0de8fdacd8.png)

## Application Repo
https://github.com/MohamedEl-Sayed28/bakehouse-ITI

## Lessons learned

I learned how to configure kubernetes cluster on AWS, acquired experiences on AWS platform and learned how to use all the tools together for development life cycle 
