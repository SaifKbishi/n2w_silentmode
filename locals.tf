locals {
  common_tags = {
    company = var.company
    project = "${var.company}-${var.project}"
  }

  #s3_bucket_name = "globo-web-app-${random_integer.s3.result}"

  policy1 = jsondecode(file("./permissions/aws_policy_permissions_Enterprise_BYOL_1.json"))
  policy2 = jsondecode(file("./permissions/aws_policy_permissions_Enterprise_BYOL_2.json"))
  #policy3 = jsondecode(file("./permissions/aws_policy_permissions_Enterprise_BYOL_3.json"))

  merged_policy = {
    Version   = "2012-10-17"
    Statement = concat(local.policy1.Statement, local.policy2.Statement)
  }
}


