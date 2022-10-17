//Using Terraform to build pipeline to launch Hello-World-API

//Define the Stack 
- AWS IAM: will give roles to services in order for pipeline to run
- AWS ALB (TG): will load balance services in ECS cluster
- AWS ECS: will host API
- AWS CodeBuild: will build docker image
- AWS Code Pipeline: automate build
- AWS S3: artifactory

//Deine the build pipeline and how you will take a Dockerfile and turn it into a running container
- I will use a buildspec.yml to build the dockerfile from within a github repo and store it within an ECR, Codepipeline will then deploy this image from the ECR into the ECS cluster

//Implement stack (Terraform)
- This repository containers the terraform files necessary for creation of docker image to deployment within a cluster