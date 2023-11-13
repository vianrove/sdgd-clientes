resource "azurerm_resource_group" "res-0" {
  location = "eastus"
  name     = "SDGD-group"
}

### Front door profile set-up
resource "azurerm_cdn_frontdoor_profile" "res-1" {
  name                     = "FD-profile"
  resource_group_name      = "SDGD-group"
  response_timeout_seconds = 60
  sku_name                 = "Standard_AzureFrontDoor"
  tags = {
    Global = "FDProfile"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
### Front door endpoints
resource "azurerm_cdn_frontdoor_endpoint" "res-2" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-1.id
  name                     = "sdgd-carrito"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-1,
    azurerm_linux_web_app.res-82
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "res-4" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-1.id
  name                     = "sdgd-clientes"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-1,
    azurerm_linux_web_app.res-42
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "res-6" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-1.id
  name                     = "sdgd-documentos"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-1,
    azurerm_linux_web_app.res-52
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "res-8" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-1.id
  name                     = "sdgd-login"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-1,
    azurerm_linux_web_app.res-62
  ]
}
resource "azurerm_cdn_frontdoor_endpoint" "res-10" {
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.res-1.id
  name                     = "sdgd-pasarela"
  depends_on = [
    azurerm_cdn_frontdoor_profile.res-1,
    azurerm_linux_web_app.res-72
  ]
}

### Mongo database
resource "azurerm_cosmosdb_account" "res-27" {
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
    azurerm_resource_group.res-0,
  ]
}

### Storage account
resource "azurerm_storage_account" "res-33" {
  account_replication_type         = "RAGRS"
  account_tier                     = "Standard"
  cross_tenant_replication_enabled = false
  location                         = "eastus"
  name                             = "sdgd"
  resource_group_name              = "SDGD-group"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

### Service plan EAST-US
resource "azurerm_service_plan" "res-40" {
  location            = "eastus"
  name                = "AppServicePlan-Region1"
  os_type             = "Linux"
  resource_group_name = "SDGD-group"
  sku_name            = "F1"
  tags = {
    Region1 = "AppServicePlan"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

### Service plan WEST-US
resource "azurerm_service_plan" "res-41" {
  location            = "westus"
  name                = "AppServicePlan-Region2"
  os_type             = "Linux"
  resource_group_name = "SDGD-group"
  sku_name            = "F1"
  tags = {
    Region2 = "AppServicePlan"
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}

variable "imagebuild" {
  type = string
  description = "the latest image build version"
}

### Clientes api (docker)
resource "azurerm_linux_web_app" "res-42" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
    PASARELA_API_URL                    = azurerm_cdn_frontdoor_endpoint.res-10.host_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-clientes-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.res-40.id
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
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
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
    azurerm_service_plan.res-40,
  ]
}
### Clientes api (docker)
resource "azurerm_linux_web_app" "res-47" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
    PASARELA_API_URL                    = azurerm_cdn_frontdoor_endpoint.res-10.host_name
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-clientes-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.res-41.id
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
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
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
    azurerm_service_plan.res-41,
  ]
}
### Documentos api (docker)
resource "azurerm_linux_web_app" "res-52" {
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
  service_plan_id     = azurerm_service_plan.res-40.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/gestiondocumental2:latest"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.res-40,
  ]
}
### Documentos api (docker)
resource "azurerm_linux_web_app" "res-57" {
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
  service_plan_id     = azurerm_service_plan.res-41.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/gestiondocumental2:latest"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.res-41,
  ]
}
### Login api (docker)
resource "azurerm_linux_web_app" "res-62" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
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
  service_plan_id     = azurerm_service_plan.res-40.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/nodelogin:latest"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.res-40,
  ]
}
### Login api (docker)
resource "azurerm_linux_web_app" "res-67" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
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
  service_plan_id     = azurerm_service_plan.res-41.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/nodelogin:latest"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.res-41,
  ]
}
### Pasarela api (docker)
resource "azurerm_linux_web_app" "res-72" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "eastus"
  name                = "sdgd-pasarela-east"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.res-40.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/api-pasarela:1.2"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
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
    azurerm_service_plan.res-40,
  ]
}
### Pasarela api (docker)
resource "azurerm_linux_web_app" "res-77" {
  app_settings = {
    DOCKER_ENABLE_CI                    = "true"
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "westus"
  name                = "sdgd-pasarela-west"
  resource_group_name = "SDGD-group"
  service_plan_id     = azurerm_service_plan.res-41.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "vianrove/api-pasarela:1.2"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
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
    azurerm_service_plan.res-41,
  ]
}
### Carrito api (docker)
resource "azurerm_linux_web_app" "res-82" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
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
  service_plan_id     = azurerm_service_plan.res-40.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/servicecarrito:latest"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.res-40,
  ]
}
### Carrito api (docker)
resource "azurerm_linux_web_app" "res-87" {
  app_settings = {
    MONGODB_URI                         = azurerm_cosmosdb_account.res-27.connection_strings[0]
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
  service_plan_id     = azurerm_service_plan.res-41.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name = "jhonpilot/servicecarrito:latest"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [azurerm_cdn_frontdoor_profile.res-1.resource_guid]
        x_fd_health_probe = []
        x_forwarded_for   = []
        x_forwarded_host  = []
      }]
      priority    = 100
      service_tag = "AzureFrontDoor.Backend"
    }
  }
  depends_on = [
    azurerm_service_plan.res-41,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-3" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.res-2.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.res-12.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.res-13.id, azurerm_cdn_frontdoor_origin.res-14.id]
  name                          = "api-carrito"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.res-2,
    azurerm_cdn_frontdoor_origin_group.res-12,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-5" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.res-4.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.res-15.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.res-16.id, azurerm_cdn_frontdoor_origin.res-17.id]
  name                          = "api-clientes"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.res-4,
    azurerm_cdn_frontdoor_origin_group.res-15,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-7" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.res-6.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.res-18.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.res-19.id, azurerm_cdn_frontdoor_origin.res-20.id]
  name                          = "api-documentos"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.res-6,
    azurerm_cdn_frontdoor_origin_group.res-18,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-9" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.res-8.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.res-21.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.res-22.id, azurerm_cdn_frontdoor_origin.res-23.id]
  name                          = "api-login"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.res-8,
    azurerm_cdn_frontdoor_origin_group.res-21,
  ]
}

resource "azurerm_cdn_frontdoor_route" "res-11" {
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.res-10.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.res-24.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.res-25.id, azurerm_cdn_frontdoor_origin.res-26.id]
  name                          = "api-pasarela"
  patterns_to_match             = ["/*"]
  supported_protocols           = ["Http", "Https"]
  depends_on = [
    azurerm_cdn_frontdoor_endpoint.res-10,
    azurerm_cdn_frontdoor_origin_group.res-24,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "res-12" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.res-1.id
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
    azurerm_cdn_frontdoor_profile.res-1,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-13" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-12.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-82.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.res-82.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-12,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-14" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-12.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-87.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.res-87.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-12,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "res-15" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.res-1.id
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
    azurerm_cdn_frontdoor_profile.res-1,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-16" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-15.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-42.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.res-42.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-15,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-17" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-15.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-47.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.res-47.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-15,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "res-18" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.res-1.id
  name                                                      = "sdgd-docuentos"
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
    azurerm_cdn_frontdoor_profile.res-1,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-19" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-18.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-52.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.res-52.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-18,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-20" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-18.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-57.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.res-57.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-18,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "res-21" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.res-1.id
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
    azurerm_cdn_frontdoor_profile.res-1,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-22" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-21.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-62.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.res-62.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-21,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-23" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-21.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-67.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.res-67.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-21,
  ]
}
resource "azurerm_cdn_frontdoor_origin_group" "res-24" {
  cdn_frontdoor_profile_id                                  = azurerm_cdn_frontdoor_profile.res-1.id
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
    azurerm_cdn_frontdoor_profile.res-1,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-25" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-24.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-72.default_hostname
  name                           = "api-region1"
  origin_host_header             = azurerm_linux_web_app.res-72.default_hostname
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-24,
  ]
}
resource "azurerm_cdn_frontdoor_origin" "res-26" {
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.res-24.id
  certificate_name_check_enabled = true
  enabled                        = true
  host_name                      = azurerm_linux_web_app.res-77.default_hostname
  name                           = "api-region2"
  origin_host_header             = azurerm_linux_web_app.res-77.default_hostname
  priority                       = 2
  weight                         = 1000
  depends_on = [
    azurerm_cdn_frontdoor_origin_group.res-24,
  ]
}
