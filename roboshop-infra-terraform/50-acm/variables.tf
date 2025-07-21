variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "roboshop"
        Terraform = "true"
        Environment = "dev"
    }
}


variable "zone_name" {
    default = "hitaws82s.fun"
}

variable "zone_id" {
    default = "Z07538852BUCVZ4G0JPBR"
}
