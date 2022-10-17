resource "aws_codebuild_project" "Docker-build-hello-api" {
  name           = "Docker-build-hello-api"
  description    = "build_dockerfile_containing-api"
  build_timeout  = "5"
  queued_timeout = "5"

  service_role = aws_iam_role.CodeBuildTaskRole.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "SOME_KEY1"
      value = "SOME_VALUE1"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/eoyebami/hello-world-api.git"
    git_clone_depth = 1
  }

  source_version = "main"

 logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
 } 

  tags = {
    Environment = "Test"
  }
}


resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.eoyebami_bucket_api.bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:738921266859:connection/d65fa872-8a7c-42a7-97df-d9851c4d4afd"
        FullRepositoryId = "eoyebami/hello-world-api"
        BranchName       = "main"
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "Docker-build-hello-api"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName      = "hello-world"
        ServiceName      = "hello-api-service"

      }
    }
  }
}

resource "aws_s3_bucket" "eoyebami_bucket_api" {
  bucket = "eoyebami-bucket-api"
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.eoyebami_bucket_api.bucket
  acl    = "private"
}