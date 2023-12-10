#
# variables
#

variable project_name {
  default = "github-action-ecr"
}

variable region {
  default = "eu-west-1"
}

variable profile {
  default = "default"
}

variable ecr_image {
  default = "200268818177.dkr.ecr.eu-west-1.amazonaws.com/github-action-ecr:latest"
}

variable desired_count {
  default = 2
}