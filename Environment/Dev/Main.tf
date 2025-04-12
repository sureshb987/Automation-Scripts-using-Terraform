module "vpc" {
  source        = "../../modules/vpc"
  vpc_cidr      = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs           = ["ap-south-1a", "ap-south-1b"]
  environment   = "dev"
}

module "eks" {
  source        = "../../modules/eks"
  cluster_name  = "dev-eks"
  k8s_version   = "1.27"
  subnets       = module.vpc.public_subnets
  vpc_id        = module.vpc.vpc_id
  key_name      = var.key_name
}

module "rds" {
  source        = "../../modules/rds"
  environment   = "dev"
  db_name       = "devdb"
  db_user       = "devuser"
  db_password   = var.db_password
  subnet_ids    = module.vpc.public_subnets
  sg_ids        = [module.eks.cluster_security_group_id]
}
