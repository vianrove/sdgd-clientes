### Pasarela api (docker)
resource "azurerm_linux_web_app" "web-api-pasarela1" {
  app_settings = {
    MONGODB_URI                         = var.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "eastus"
  name                = "dochub-pasarela-east"
  resource_group_name = "DocHub-group"
  service_plan_id     = var.serviceplan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name   = "vianrove/api-pasarela:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [var.frontdoorprofile.resource_guid]
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
}
### Pasarela api (docker)
resource "azurerm_linux_web_app" "web-api-pasarela2" {
  app_settings = {
    DOCKER_ENABLE_CI                    = "true"
    MONGODB_URI                         = var.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
  https_only          = true
  location            = "westus3"
  name                = "dochub-pasarela-west"
  resource_group_name = "DocHub-group"
  service_plan_id     = var.serviceplan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name   = "vianrove/api-pasarela:${var.imagebuild}"
      docker_registry_url = "https://index.docker.io"
    }
    always_on  = false
    ftps_state = "FtpsOnly"
    ip_restriction {
      headers = [{
        x_azure_fdid      = [var.frontdoorprofile.resource_guid]
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
}
