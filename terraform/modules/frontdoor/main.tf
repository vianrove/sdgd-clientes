### Front door profile set-up
resource "azurerm_cdn_frontdoor_profile" "fdprofile" {
  name                     = "FD-profile"
  resource_group_name      = var.resourcegroupname
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
  tags = {
    Global = "FDProfile"
  }
  depends_on = [
    var.serviceplan1,
    var.serviceplan2
  ]
}


### Front door endpoints
resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-carrito" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "dochub-carrito"
}

resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-clientes" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "dochub-clientes"
}

resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-documentos" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "dochub-documentos"
}

resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-login" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "dochub-login"
}

resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-pasarela" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "dochub-pasarela"
}

resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-front" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "dochub-front"
}

### Front door routes
resource "azurerm_cdn_frontdoor_route" "fdroute-carrito" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-carrito.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-carrito1.id, azurerm_cdn_frontdoor_origin.fdorig-carrito2.id]
  name                          = "api-carrito"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-clientes" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-clientes.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-clientes1.id, azurerm_cdn_frontdoor_origin.fdorig-clientes2.id]
  name                          = "api-clientes"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-documentos" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-documentos.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-documentos1.id, azurerm_cdn_frontdoor_origin.fdorig-documentos2.id]
  name                          = "api-documentos"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-login" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-login.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-login.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-login1.id, azurerm_cdn_frontdoor_origin.fdorig-login1.id]
  name                          = "api-login"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-pasarela" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-pasarela.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-pasarela1.id, azurerm_cdn_frontdoor_origin.fdorig-pasarela2.id]
  name                          = "api-pasarela"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-front" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-front.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-pasarela1.id, azurerm_cdn_frontdoor_origin.fdorig-pasarela2.id]
  name                          = "dochub-front"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
}

### Front door origins
resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-carrito" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "dochub-carrito"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-carrito1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.carritoapi1.default_hostname
  name                           = "api-region1"
  origin_host_header             = var.carritoapi1.default_hostname
  weight                         = 1000
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-carrito2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.carritoapi2.default_hostname
  name                           = "api-region2"
  origin_host_header             = var.carritoapi2.default_hostname
  priority                       = 2
  weight                         = 1000
}


resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-clientes" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "dochub-clientes"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-clientes1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.clientesapi1.default_hostname
  name                           = "api-region1"
  origin_host_header             = var.clientesapi1.default_hostname
  weight                         = 1000
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-clientes2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.clientesapi2.default_hostname
  name                           = "api-region2"
  origin_host_header             = var.clientesapi2.default_hostname
  priority                       = 2
  weight                         = 1000
}


resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-documentos" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "dochub-documentos"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-documentos1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.documentosapi1.default_hostname
  name                           = "api-region1"
  origin_host_header             = var.documentosapi1.default_hostname
  weight                         = 1000
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-documentos2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.documentosapi2.default_hostname
  name                           = "api-region2"
  origin_host_header             = var.documentosapi2.default_hostname
  priority                       = 2
  weight                         = 1000
}


resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-login" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "dochub-login"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-login1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-login.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.loginapi1.default_hostname
  name                           = "api-region1"
  origin_host_header             = var.loginapi1.default_hostname
  weight                         = 1000
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-login2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-login.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.loginapi2.default_hostname
  name                           = "api-region2"
  origin_host_header             = var.loginapi2.default_hostname
  priority                       = 2
  weight                         = 1000
}


resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-pasarela" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "dochub-pasarela"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-pasarela1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.pasarelaapi1.default_hostname
  name                           = "api-region1"
  origin_host_header             = var.pasarelaapi1.default_hostname
  weight                         = 1000
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-pasarela2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.pasarelaapi2.default_hostname
  name                           = "api-region2"
  origin_host_header             = var.pasarelaapi2.default_hostname
  priority                       = 2
  weight                         = 1000
}


resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-front" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "dochub-front"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-front1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-front.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.frontservice1.default_hostname
  name                           = "front-region1"
  origin_host_header             = var.frontservice1.default_hostname
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_origin" "fdorig-front2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-front.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = var.frontservice2.default_hostname
  name                           = "front-region2"
  origin_host_header             = var.frontservice2.default_hostname
  priority                       = 2
  weight                         = 1000
}