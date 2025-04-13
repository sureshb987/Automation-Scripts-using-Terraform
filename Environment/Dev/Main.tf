provider "aws" {
  region = "ap-south-1"
}

module "CorporateProject_vpc" {
  source         = "./modules/Vpc"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["ap-south-1a", "ap-south-1b"]
  environment    = "dev"
}

module "CorporateProject_eks" {
  source       = "./modules/eks"
  cluster_name = "CorporateProject-cluster"
  k8s_version  = "1.27"
  subnets      = module.CorporateProject_vpc.public_subnets
  vpc_id       = module.CorporateProject_vpc.vpc_id
  key_name     = "Devops project"
}

module "CorporateProject_rds" {
  source      = "./modules/Rds"
  environment = "dev"
  db_name     = "CorporateProject_db"
  db_user     = "devuser"
  db_password = var.db_password
  subnet_ids  = module.CorporateProject_vpc.public_subnets
  sg_ids      = [module.CorporateProject_eks.cluster_security_group_id]
}
