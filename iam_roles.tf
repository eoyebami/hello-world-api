#------------------------------------------------------------------#
# Roles for ECS cluster                                            #                     #
#------------------------------------------------------------------#
resource "aws_iam_policy" "ecsTask_policy" {
  name = "ecsTask-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow"
            Action = [ "ecr:*", "logs:CreateLogStream", "logs:PutLogEvents" ]
            Resource = "*"
        },
    ]
})
}

resource "aws_iam_role" "ecsTaskRole" {
  name = "ecsTaskRole"
  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.ecsTaskRole.id
  policy_arn = aws_iam_policy.ecsTask_policy.arn
}
resource "aws_iam_role_policy_attachment" "test-attach_1" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.ecsTaskRole.id
}

#------------------------------------------------------------------#
# Roles for CodeBuild                                              #                  #
#------------------------------------------------------------------#
resource "aws_iam_role" "CodeBuildTaskRole" {
  name = "CodeBuildTaskRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "tf-cicd-build-policies-1" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*","iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "CodeBuildTask_policy" {
    name = "CodeBuildTask-policy"
    path = "/"
    description = "Codebuild policy"
    policy = data.aws_iam_policy_document.tf-cicd-build-policies-1.json
}

resource "aws_iam_role_policy_attachment" "test-attach_2" {
    policy_arn  = aws_iam_policy.CodeBuildTask_policy.arn
    role        = aws_iam_role.CodeBuildTaskRole.id
    depends_on = [
      aws_iam_policy.CodeBuildTask_policy
    ]
}

resource "aws_iam_role_policy_attachment" "test-attach_3" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.CodeBuildTaskRole.id
    depends_on = [
      aws_iam_policy.CodeBuildTask_policy
    ]
}

#------------------------------------------------------------------#
# Roles for CodePipeline                                           #                    #
#------------------------------------------------------------------#
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

 assume_role_policy = jsonencode({
  Version = "2012-10-17",
  Statement = [
    {
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }
  ]
})
}

data "aws_iam_policy_document" "tf-cicd-pipeline-policies-2" {
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["*"]
        effect = "Allow"
    }
    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codedeploy:*", "codebuild:*", "ecr:*", "ecs:*", "iam:*",]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  path = "/"
  description = "Pipeline policy"
  policy = data.aws_iam_policy_document.tf-cicd-pipeline-policies-2.json
}

resource "aws_iam_role_policy_attachment" "test-attach_4" {
  role       = aws_iam_role.codepipeline_role.id
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_iam_role_policy_attachment" "test-attach_5" {
    policy_arn  = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
    role        = aws_iam_role.codepipeline_role.id
}