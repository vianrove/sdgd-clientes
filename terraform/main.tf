### RESOURCE GROUP
module "resourcegroup" {
  source = "./modules/resourcegroup"
}

### MONGODB
module "mongodb" {
  source            = "./modules/mongodb"
  resourcegroupname = module.resourcegroup.resourcegroupname
}

### STORAGE ACCOUNT
module "storageaccount" {
  source            = "./modules/storageaccount"
  resourcegroupname = module.resourcegroup.resourcegroupname
}

### APP SERVICE PLANS
module "appserviceplan" {
  source            = "./modules/appserviceplan"
  resourcegroupname = module.resourcegroup.resourcegroupname
}


### APP SERVICES
variable "imagebuild" {
  type        = string
  description = "the latest image build version"
}

module "appserviceclientes" {
  source           = "./modules/appservices/clientes"
  imagebuild       = var.imagebuild
  mongodb          = module.mongodb.mongodb
  serviceplan1     = module.appserviceplan.serviceplan1
  serviceplan2     = module.appserviceplan.serviceplan2
  frontdoorprofile = module.frontdoor.frontdoorprofile
  pasarelaendpoint = module.frontdoor.pasarelaendpoint
}

module "appservicedocumentos" {
  source           = "./modules/appservices/documentos"
  imagebuild       = var.imagebuild
  mongodb          = module.mongodb.mongodb
  serviceplan1     = module.appserviceplan.serviceplan1
  serviceplan2     = module.appserviceplan.serviceplan2
  frontdoorprofile = module.frontdoor.frontdoorprofile
}

module "appservicecarrito" {
  source           = "./modules/appservices/carrito"
  imagebuild       = var.imagebuild
  mongodb          = module.mongodb.mongodb
  serviceplan1     = module.appserviceplan.serviceplan1
  serviceplan2     = module.appserviceplan.serviceplan2
  frontdoorprofile = module.frontdoor.frontdoorprofile
}

module "appservicefront" {
  source           = "./modules/appservices/front"
  imagebuild       = var.imagebuild
  serviceplan1     = module.appserviceplan.serviceplan1
  serviceplan2     = module.appserviceplan.serviceplan2
  frontdoorprofile = module.frontdoor.frontdoorprofile
}

module "appservicelogin" {
  source           = "./modules/appservices/login"
  imagebuild       = var.imagebuild
  mongodb          = module.mongodb.mongodb
  serviceplan1     = module.appserviceplan.serviceplan1
  serviceplan2     = module.appserviceplan.serviceplan2
  frontdoorprofile = module.frontdoor.frontdoorprofile
}

module "appservicepasarela" {
  source           = "./modules/appservices/pasarela"
  imagebuild       = var.imagebuild
  mongodb          = module.mongodb.mongodb
  serviceplan1     = module.appserviceplan.serviceplan1
  serviceplan2     = module.appserviceplan.serviceplan2
  frontdoorprofile = module.frontdoor.frontdoorprofile
}


### FRONTDOOR
module "frontdoor" {
  source            = "./modules/frontdoor"
  resourcegroupname = module.resourcegroup.resourcegroupname
  serviceplan1 = module.appserviceplan.serviceplan1
  serviceplan2 = module.appserviceplan.serviceplan2
  carritoapi1       = module.appservicecarrito.carritoapi1
  carritoapi2       = module.appservicecarrito.carritoapi2
  clientesapi1      = module.appserviceclientes.clientesapi1
  clientesapi2      = module.appserviceclientes.clientesapi2
  documentosapi1    = module.appservicedocumentos.documentosapi1
  documentosapi2    = module.appservicedocumentos.documentosapi2
  frontservice1     = module.appservicefront.frontservice1
  frontservice2     = module.appservicefront.frontservice2
  loginapi1         = module.appservicelogin.loginapi1
  loginapi2         = module.appservicelogin.loginapi2
  pasarelaapi1      = module.appservicepasarela.pasarelaapi1
  pasarelaapi2      = module.appservicepasarela.pasarelaapi2
}
