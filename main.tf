module "vpc" {
  source        = "./modules/vpc"
  vpc_cidr      = var.vpc_cidr
  project_name  = var.project_name
}

module "igw" {
  source = "./modules/IGW"
  vpc_id = module.vpc.vpc_id
  eip_id = module.elastic-ip.eip_id
  project_name = var.project_name
}

module "elastic-ip" {
  source = "./modules/Elastic-IP"
  project_name = var.project_name
}

module "subnets" {
  source = "./modules/Subnets"
  vpc_id = module.vpc.vpc_id
  azs = var.azs
  public_subnets_cidrs = [
                      {cidr = "172.20.0.0/24", name = "Open-VPN-Az1"},
                      {cidr = "172.20.1.0/24", name = "Global-NGW-Az1"},
                      {cidr = "172.20.2.0/24", name = "Global-NGW-Az2"},
                      {cidr = "172.20.10.0/24", name = "Uat-ALB-Az1"},
                      {cidr = "172.20.11.0/24", name = "Uat-ALB-Az2"},
                      {cidr = "172.20.12.0/24", name = "Prod-ALB-Az1"},
                      {cidr = "172.20.13.0/24", name = "Prod-ALB-Az2"},
                      ]
  private_subnets_cidrs = [            
             {cidr = "172.20.14.0/24", name = "Uat-App-Az1"},
             {cidr = "172.20.15.0/24", name = "Uat-App-Az2"},
             {cidr = "172.20.16.0/24", name = "Uat-DB-Az1"},
             {cidr = "172.20.17.0/24", name = "Uat-DB-Az2"},
             {cidr = "172.20.18.0/24", name = "Prod-DB-Az1"},
             {cidr = "172.20.19.0/24", name = "Prod-DB-Az2"},
             {cidr = "172.20.20.0/24", name = "Prod-App-Az1"},
             {cidr = "172.20.21.0/24", name = "Prod-App-Az2"},
             {cidr = "172.20.22.0/24", name = "VM-Subnet-Az1"},
             {cidr = "172.20.23.0/24", name = "VM-Subnet-Az2"}
]
  
}

module "nat" {
  source = "./modules/NAT"
  eip_id = module.elastic-ip.eip_id
  public_subnets_cidrs = module.subnets.public_subnets[0]
  project_name = var.project_name
}

# ROUTE TABLE MODULE

module "route_tables" {
  source = "./modules/Route-tables"

  vpc_id       = module.vpc.vpc_id
  gateway_id   = module.igw.igw_id
  nat_id       = module.nat.nat_id
  project_name = var.project_name

  public_subnets_cidrs  = module.subnets.public_subnets
  private_subnets_cidrs = module.subnets.private_subnets
}

module "nacl" {
  source = "./modules/Nacls"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name

  vpn_subnet_id = module.subnets.public_subnets[0]

  nat_subnets = [
    module.subnets.public_subnets[1],
    module.subnets.public_subnets[2]
  ]

  alb_subnets = [
    module.subnets.public_subnets[3],
    module.subnets.public_subnets[4],
    module.subnets.public_subnets[5],
    module.subnets.public_subnets[6]
  ]

  app_cidr = "172.20.14.0/22"

  db_subnets = [
    module.subnets.private_subnets[2],
    module.subnets.private_subnets[3],
    module.subnets.private_subnets[4],
    module.subnets.private_subnets[5]
  ]

  admin_ip = "172.20.0.0/18"
}

module "db_nacl" {
  source = "./modules/Nacl-DB"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name

  app_cidr = "172.20.14.0/22"   # app subnets range

  db_subnets = [
    module.subnets.private_subnets[2],
    module.subnets.private_subnets[3],
    module.subnets.private_subnets[4],
    module.subnets.private_subnets[5]
  ]
}

module "vm_nacl" {
  source = "./modules/Nacl-VM"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name

  vm_subnets = [
    module.subnets.private_subnets[8],
    module.subnets.private_subnets[9]
  ]
}