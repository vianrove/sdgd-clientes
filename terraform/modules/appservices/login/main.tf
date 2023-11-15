### Login api (docker)
resource "azurerm_linux_web_app" "web-api-login1" {
  app_settings = {
    MONGODB_URI                         = var.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-dochub.mysql.database.azure.com"
    password                            = "dochub8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "eastus"
  name                = "dochub-login-east"
  resource_group_name = "DocHub-group"
  service_plan_id     = var.serviceplan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name   = "jhonpilot/nodelogin:${var.imagebuild}"
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
}
### Login api (docker)
resource "azurerm_linux_web_app" "web-api-login2" {
  app_settings = {
    MONGODB_URI                         = var.mongodb.connection_strings[0]
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    database                            = "gestiondocumental"
    db_port                             = "3306"
    host                                = "mysql-instance-dochub.mysql.database.azure.com"
    password                            = "dochub8@23"
    user                                = "admin378"
  }
  https_only          = true
  location            = "westus3"
  name                = "dochub-login-west"
  resource_group_name = "DocHub-group"
  service_plan_id     = var.serviceplan2.id
  tags = {
    Region2 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name   = "jhonpilot/nodelogin:${var.imagebuild}"
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
}