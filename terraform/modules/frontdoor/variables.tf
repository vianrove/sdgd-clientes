variable "resourcegroupname" {
  type        = string
  description = "resource group name"
}

variable "serviceplan1" {
  type = any
  description = "App service plan1"
}

variable "serviceplan2" {
  type = any
  description = "App service plan2"
}

variable "carritoapi1" {
  type        = any
  description = "App Service de la api de carrito1"
}
variable "carritoapi2" {
  type        = any
  description = "App Service de la api de carrito2"
}

variable "clientesapi1" {
  type        = any
  description = "App service de la api de clientes1"
}
variable "clientesapi2" {
  type        = any
  description = "App service de la api de clientes2"
}

variable "documentosapi1" {
  type        = any
  description = "App service de la api de documentos1"
}
variable "documentosapi2" {
  type        = any
  description = "App service de la api de documentos2"
}

variable "frontservice1" {
  type        = any
  description = "App service del front end1"
}
variable "frontservice2" {
  type        = any
  description = "App service del front end2"
}

variable "loginapi1" {
  type        = any
  description = "App service de la api de login1"
}
variable "loginapi2" {
  type        = any
  description = "App service de la api de login2"
}

variable "pasarelaapi1" {
  type        = any
  description = "App service de la api de pasarela1"
}
variable "pasarelaapi2" {
  type        = any
  description = "App service de la api de pasarela2"
}