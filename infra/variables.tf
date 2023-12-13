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



variable ecs_instance_ami_id {
  default = "ami-049b0abf844cab8d7"
}


variable ecs_instance_type {
  default = "t2.micro"
}

variable desired_count {
  default = "3"
}

variable max_count {
  default = "4"
}

variable min_count {
  default = "2"
}