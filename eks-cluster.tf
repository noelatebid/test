# # Kubernetes provider
# # https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster#optional-configure-terraform-kubernetes-provider
# # To learn how to schedule deployments and services using the provider, go here: https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes.

provider "kubernetes" {
  //  load_config_file       = "false"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "17.1.0"
  cluster_name = local.prefix
  subnets      = module.vpc.private_subnets

  cluster_version = "1.20"
  tags            = local.default_tags

  vpc_id               = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group"
      instance_type                 = "t2.medium"
      root_encrypted                = true
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
    }
  ]

  map_roles = (var.environment == "prod") ? []: [{
    // @TODO - need to get the acct number here - this is stage
    rolearn = "arn:aws:iam::444266008906:role/OrganizationAccountAccessRole"
    username = "OrganizationAccountAccessRole"
    groups   = ["system:masters"]
  }]

  map_users = (var.environment == "prod") ? ([
    {
      userarn  = "arn:aws:iam::410433510248:user/system/githubactions"
      username = "githubactions"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::410433510248:user/acotroneo"
      username = "acotroneo"
      groups   = ["system:masters"]
    }
  ]): ([
    {
//      userarn  = "arn:aws:iam::444266008906:user/system/githubactions-staging"
      userarn  = aws_iam_user.githubactions.arn
      username = aws_iam_user.githubactions.name
      groups   = ["system:masters"]
    }
  ])
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "external" "thumbprint" {
  program = [format("%s/bin/thumbprint.sh", path.module), var.region]
}

resource "aws_iam_openid_connect_provider" "cluster_oid_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

module "alb_ingress_controller" {
  source  = "iplabs/alb-ingress-controller/kubernetes"
  version = "3.4.0"

  providers = {
    kubernetes = kubernetes
  }

  k8s_cluster_type = "eks"
  k8s_namespace    = "kube-system"

  aws_region_name  = var.region
  k8s_cluster_name = data.aws_eks_cluster.cluster.name
  aws_tags         = local.default_tags
}
