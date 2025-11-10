locals {
  subnets = cidrsubnets(var.vnet_subnet, 8, 2)

  postgres_subnet = local.subnets[0]
  k8s_subnet      = local.subnets[1]

}
