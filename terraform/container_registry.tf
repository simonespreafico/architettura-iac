/* Containers repos ECR */

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "ecr_policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["903266019256"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

resource "aws_ecr_repository_policy" "repository_gateway_policy" {
  repository = aws_ecr_repository.gateway.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository_policy" "repository_user_policy" {
  repository = aws_ecr_repository.user.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository_policy" "repository_certificate_policy" {
  repository = aws_ecr_repository.certificate.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository_policy" "repository_frontend_policy" {
  repository = aws_ecr_repository.frontend.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository_policy" "repository_question_policy" {
  repository = aws_ecr_repository.question.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository_policy" "repository_template_policy" {
  repository = aws_ecr_repository.template.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository_policy" "repository_quiz_policy" {
  repository = aws_ecr_repository.quiz.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}

resource "aws_ecr_repository" "quiz" {
  name                 = "application/quiz"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "template" {
  name                 = "application/template"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "question" {
  name                 = "application/question"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "gateway" {
  name                 = "application/gateway"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "user" {
  name                 = "application/user"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "certificate" {
  name                 = "application/certificate"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "application/frontend"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}