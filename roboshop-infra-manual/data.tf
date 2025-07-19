data "aws_ami" "ami" {

	most_recent      = true
	owners = ["973714476881"]  # your owner ID of AMI
	
	filter {
		name   = "name"
		values = ["RHEL-9-DevOps-Practice"]   # I have used community AMI, you can use your own AMI or key-value pair setup to login the ec2 instances
	}
	
	filter {
		name   = "root-device-type"
		values = ["ebs"]
	}

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}