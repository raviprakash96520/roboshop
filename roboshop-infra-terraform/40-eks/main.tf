resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  //public_key = file("~/.ssh/eks.pub")
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAwrcfiQKv9v5spMRPVt0KiP+1LL2F10v3KfOC0P/9GchUoYQIeUVBSCMYBbcQdXp0dueCvo0/Jnu8VoPY6JNxjMp8KPcFPSD820/byrLX+nZSvBUyob+VjTVzaCn7B0bDNGszOfwMN9muq/CTMcMxQOIJ4jFecOgt7SgZbbNh7g6/2q5SJOuFiWZkqgsxvbAytVA3/FL0v5UU+Ba7Kh1Ugu1skQNDClvpZg+NzHHQNP6E4EWAtZSQUflPS83qtvJPF6cXj9bFb7h5kG+i2qWsB6+iujC+964XWImGr8ftVOpe6JWxRcg+C++bTJgz4sdWxCBbo/KtpzjLzVtvOpAI10V9Y+KGkPQuEVYty9Wk1HzLb13TS+iWbXXdrW0eadFl5nGsyrvE1Yen+Tae7J6ayRmjrfYw6Dio1rAmTW1Sms+Df4cESzpVsjEALfoqJmNxDJy6SLpZXQiNXhdeIAxkotnedo0fEHbsx15nx/0EJT9bHCfyh/l6g+l+4O2mjOE= user@AshDexter-T480"
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"


  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size      = 3
    #   max_size      = 10
    #   desired_size  = 3
    #   capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }
    green = {
      min_size      = 3
      max_size      = 3
      desired_size  = 3
      capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags
}