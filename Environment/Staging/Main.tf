module "CorporateProject_vpc" {
  source         = "../../Cluster Server"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["ap-south-1a", "ap-south-1b"]
  environment    = var.environment
}

module "CorporateProject_eks" {
  source       = "../../Cluster Server"
  cluster_name = "${var.environment}-eks"
  k8s_version  = "1.27"
  subnets      = module.CorporateProject_vpc.public_subnets
  vpc_id       = module.CorporateProject_vpc.vpc_id
  key_name     = var.key_name
}

module "CorporateProject_rds" {
  source      = "../../Cluster Server"
  environment = var.environment
  db_name     = "${var.environment}db"
  db_user     = "${var.environment}user"
  db_password = var.db_password
  subnet_ids  = module.CorporateProject_vpc.public_subnets
  sg_ids      = [module.CorporateProject_eks.cluster_security_group_id]
}
