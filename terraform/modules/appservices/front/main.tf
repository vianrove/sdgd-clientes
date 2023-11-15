### DocHub Front (docker)
resource "azurerm_linux_web_app" "web-front1" {
  https_only          = true
  location            = "eastus"
  name                = "dochub-front-east"
  resource_group_name = "DocHub-group"
  service_plan_id     = var.serviceplan1.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name   = "vianrove/dochub-front:${var.imagebuild}"
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

resource "azurerm_linux_web_app" "web-front2" {
  https_only          = true
  location            = "westus3"
  name                = "dochub-front-west"
  resource_group_name = "DocHub-group"
  service_plan_id     = var.serviceplan2.id
  tags = {
    Region1 = "Api"
  }
  site_config {
    application_stack {
      docker_image_name   = "vianrove/dochub-front:${var.imagebuild}"
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
