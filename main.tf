resource "azurerm_resource_group" "sdgd-rg" {
  location = "eastus"
  name     = "SDGD-group"
}

### Front door profile set-up
resource "azurerm_cdn_frontdoor_profile" "fdprofile" {
  name                     = "FD-profile"
  resource_group_name      = "SDGD-group"
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
  tags = {
    Global = "FDProfile"
  }
  depends_on = [
    azurerm_resource_group.sdgd-rg,
  ]
}
### Front door endpoints
resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-carrito" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "sdgd-carrito"
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
    azurerm_linux_web_app.web-api-carrito1
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-clientes" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "sdgd-clientes"
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
    azurerm_linux_web_app.web-api-clientes1
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-documentos" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "sdgd-documentos"
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
    azurerm_linux_web_app.web-api-documentos1
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-login" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "sdgd-login"
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
    azurerm_linux_web_app.web-api-login1
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-pasarela" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "sdgd-pasarela"
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
    azurerm_linux_web_app.web-api-pasarela1
  ]
}

resource "azurerm_cdn_frontdoor_endpoint" "fdprofile-front" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                     = "sdgd-front"
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
    azurerm_linux_web_app.web-front1
  ]
}

### Mongo database
resource "azurerm_cosmosdb_account" "mongodb" {
  enable_free_tier    = true
  kind                = "MongoDB"
  location            = "westus"
  name                = "sdgd-mongodb"
  offer_type          = "Standard"
  resource_group_name = "SDGD-group"
  tags = {
    defaultExperience       = "Azure Cosmos DB for MongoDB API"
    hidden-cosmos-mmspecial = ""
  }
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    failover_priority = 0
    location          = "westus"
  }
  depends_on = [
    azurerm_resource_group.sdgd-rg,
  ]
}

### Storage account
resource "azurerm_storage_account" "storage-account" {
  account_replication_type         = "RAGRS"
  account_tier                     = "Standard"
  cross_tenant_replication_enabled = false
  location                         = "eastus"
  name                             = "sdgd"
  resource_group_name              = "SDGD-group"
  depends_on = [
    azurerm_resource_group.sdgd-rg,
  ]
}

### Service plan EAST-US
resource "azurerm_service_plan" "service-plan1" {
  location            = "eastus"
  name                = "AppServicePlan-Region1"
  os_type             = "Linux"
  resource_group_name = "SDGD-group"
  sku_name            = "F1"
  tags = {
    Region1 = "AppServicePlan"
  }
  depends_on = [
    azurerm_resource_group.sdgd-rg,
  ]
}

### Service plan WEST-US
resource "azurerm_service_plan" "service-plan2" {
  location            = "westus"
  name                = "AppServicePlan-Region2"
  os_type             = "Linux"
  resource_group_name = "SDGD-group"
  sku_name            = "F1"
  tags = {
    Region2 = "AppServicePlan"
  }
  depends_on = [
    azurerm_resource_group.sdgd-rg,
  ]
}

variable "imagebuild" {
  type = string
  description = "the latest image build version"
}

### SDGD Front (docker)
resource "azurerm_linux_web_app" "web-front1" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    PASARELA_API_URL                    = azurerm_cdn_frontdoor_endpoint.fdprofile-pasarela.host_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-front-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/sdgd-front:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
}

resource "azurerm_linux_web_app" "web-front2" {
  https_only          = true
  location            = "westus"
  name                = "sdgd-front-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan2.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/sdgd-front:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
}

### Clientes api (docker)
resource "azurerm_linux_web_app" "web-api-clientes1" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    PASARELA_API_URL                    = azurerm_cdn_frontdoor_endpoint.fdprofile-pasarela.host_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-clientes-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/api-clientes:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  sticky_settings {
    app_setting_names = ["MONGODB_URI", "PASARELA_API_URL"]
  }
  depends_on = [
    azurerm_service_plan.service-plan1,
  ]
}
### Clientes api (docker)
resource "azurerm_linux_web_app" "web-api-clientes2" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    PASARELA_API_URL                    = azurerm_cdn_frontdoor_endpoint.fdprofile-pasarela.host_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-clientes-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/api-clientes:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  sticky_settings {
    app_setting_names = ["MONGODB_URI", "PASARELA_API_URL"]
  }
  depends_on = [
    azurerm_service_plan.service-plan2,
  ]
}
### Documentos api (docker)
resource "azurerm_linux_web_app" "web-api-documentos1" {
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-sdgd.mysql.database.azure.com"
    password                            = "sdgd8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-documentos-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/gestiondocumental2:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.service-plan1,
  ]
}
### Documentos api (docker)
resource "azurerm_linux_web_app" "web-api-documentos2" {
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-sdgd.mysql.database.azure.com"
    password                            = "sdgd8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-documentos-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/gestiondocumental2:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.service-plan2,
  ]
}
### Login api (docker)
resource "azurerm_linux_web_app" "web-api-login1" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-sdgd.mysql.database.azure.com"
    password                            = "sdgd8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-login-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/nodelogin:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.service-plan1,
  ]
}
### Login api (docker)
resource "azurerm_linux_web_app" "web-api-login2" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-sdgd.mysql.database.azure.com"
    password                            = "sdgd8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-login-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/nodelogin:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.service-plan2,
  ]
}
### Pasarela api (docker)
resource "azurerm_linux_web_app" "web-api-pasarela1" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-pasarela-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/api-pasarela:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  sticky_settings {
    app_setting_names = ["MONGODB_URI"]
  }
  depends_on = [
    azurerm_service_plan.service-plan1,
  ]
}
### Pasarela api (docker)
resource "azurerm_linux_web_app" "web-api-pasarela2" {
  app_settings = {
    DOCKER_ENABLE_CI                    = "true"
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-pasarela-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/api-pasarela:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  sticky_settings {
    app_setting_names = ["MONGODB_URI"]
  }
  depends_on = [
    azurerm_service_plan.service-plan2,
  ]
}
### Carrito api (docker)
resource "azurerm_linux_web_app" "web-api-carrito1" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-sdgd.mysql.database.azure.com"
    password                            = "sdgd8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-shoppingcart-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/servicecarrito:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.service-plan1,
  ]
}
### Carrito api (docker)
resource "azurerm_linux_web_app" "web-api-carrito2" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-sdgd.mysql.database.azure.com"
    password                            = "sdgd8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-shoppingcart-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.service-plan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/servicecarrito:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.fdprofile.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.service-plan2,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-3" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-carrito.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-carrito1.id, azurerm_cdn_frontdoor_origin.fdorig-carrito2.id]
  name                          = "api-carrito"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.fdprofile-carrito,
    azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-5" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-clientes.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-clientes1.id, azurerm_cdn_frontdoor_origin.fdorig-clientes2.id]
  name                          = "api-clientes"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.fdprofile-clientes,
    azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-7" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-documentos.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-documentos1.id, azurerm_cdn_frontdoor_origin.fdorig-documentos2.id]
  name                          = "api-documentos"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.fdprofile-documentos,
    azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos,
  ]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-login" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-login.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-login.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-login1.id, azurerm_cdn_frontdoor_origin.fdorig-login1.id]
  name                          = "api-login"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.fdprofile-login,
    azurerm_cdn_frontdoor_origin_group.fdorig-group-login,
  ]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-pasarela" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-pasarela.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-pasarela1.id, azurerm_cdn_frontdoor_origin.fdorig-pasarela2.id]
  name                          = "api-pasarela"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.fdprofile-pasarela,
    azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela,
  ]
}

resource "azurerm_cdn_frontdoor_route" "fdroute-front" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fdprofile-front.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdorig-pasarela1.id, azurerm_cdn_frontdoor_origin.fdorig-pasarela2.id]
  name                          = "sdgd-front"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.fdprofile-front,
    azurerm_cdn_frontdoor_origin_group.fdorig-group-front,
  ]
}

resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-carrito" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "sdgd-carrito"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-carrito1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-carrito1.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.web-api-carrito1.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-carrito2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-carrito2.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.web-api-carrito2.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-carrito,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-clientes" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "sdgd-clientes"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-clientes1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-clientes1.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.web-api-clientes1.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-clientes2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-clientes2.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.web-api-clientes2.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-clientes,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-documentos" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "sdgd-documentos"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-documentos1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-documentos1.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.web-api-documentos1.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-documentos2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-documentos2.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.web-api-documentos2.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-documentos,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-login" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "sdgd-login"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-login1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-login.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-login1.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.web-api-login1.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-login,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-login2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-login.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-login2.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.web-api-login2.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-login,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-pasarela" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "sdgd-pasarela"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-pasarela1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-pasarela1.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.web-api-pasarela1.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "fdorig-pasarela2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-api-pasarela2.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.web-api-pasarela2.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela,
  ]
}

resource "azurerm_cdn_frontdoor_origin_group" "fdorig-group-front" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.fdprofile.id
  name                                                      = "sdgd-front"
  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 0
  session_affinity_enabled                                  = false
  health_probe {
    interval_in_seconds = 120
    protocol            = "Http"
    request_type        = "GET"
  }
  load_balancing {
  }
  depends_on = [
    azurerm_cdn_frontdoor_profile.fdprofile,
  ]
}

resource "azurerm_cdn_frontdoor_origin" "fdorig-front1" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-front.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-front1.default_hostname
  name                           = "front-region1"
  origin_host_header             = azurerm_linux_web_app.web-front1.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela,
  ]
}

resource "azurerm_cdn_frontdoor_origin" "fdorig-front2" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fdorig-group-front.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.web-front1.default_hostname
  name                           = "front-region2"
  origin_host_header             = azurerm_linux_web_app.web-front1.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.fdorig-group-pasarela,
  ]
}
