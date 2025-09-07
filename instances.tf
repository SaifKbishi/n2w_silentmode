##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "ami" {
  #name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  name = "/aws/service/marketplace/prod-4cyziloiqz6jk/4.4.1"
}

##################################################################################
# RESOURCES
##################################################################################

# INSTANCES #
resource "aws_instance" "n2w_v441" {
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.n2w_public_subnet.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.n2w_profile.name
  depends_on             = [aws_iam_role_policy.allow_n2w_permissions]

  user_data = <<EOF
#! /bin/bash
CPMCONFIG
[SERVER]
user=adminSaif
password=2
volume_option=new
volume_id=vol-0a5325f2868c6b2a0
time_zone=Asia/Jerusalem
allow_anonymous_reports=False
force_recovery_mode=False
CPMCONFIGEND
EOF

  tags = {
    Name    = "terraform instance 01"
    Project = local.common_tags.project
    Company = local.common_tags.company
  }

}

#volume_id=vol-0455a5fd5c5c95ae6
#password=mABg??kn?vCXY(%WMB)RJjI-W2ti9n-p
#
resource "aws_iam_role" "n2w_role" {
  name = "n2w_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "n2w_profile" {
  name = "n2w_profile"
  role = aws_iam_role.n2w_role.name

  tags = local.common_tags
}

resource "aws_iam_role_policy" "allow_n2w_permissions" {
  name = "allow_n2w_permissions"
  role = aws_iam_role.n2w_role.name

  policy = jsonencode(local.merged_policy)
}







#  tags = merge(
#    local.common_tags,
#    {
#      Name        = "N2W v4.4.0"
#      DataType    = "Logs"
#    }
#  )
