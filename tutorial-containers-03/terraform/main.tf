# Configure the Azure provider
terraform {
  required_version = ">= 0.14.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
  backend "azurerm" {
      resource_group_name  = "tutorial-terraform-backend"
      storage_account_name = "tutorialtfstate"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.name
  location = "eastus"
}

resource "azurerm_iothub" "main" {
  name                = var.name_simple
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name     = "S1"
    capacity = "1"
  }
}


resource "azurerm_container_registry" "main" {
    name                = var.name_simple
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    sku                 = "Basic"
    admin_enabled       = true
}


###########
# Useful Scripts
# Terraform does not support DPS enrollments (see this feature request: https://github.com/hashicorp/terraform-provider-azurerm/issues/11101), so it should be done by CLI
# TODO: azure login
/* resource "local_file" "enrollment-dps-create" {
    content     = <<-EOT


      az iot dps enrollment-group create \
        --resource-group ${azurerm_resource_group.main.name} \
        --dps-name ${azurerm_iothub_dps.main.name} \
        --enrollment-id rpi-standard-symkey \
        --edge-enabled true  \
        --initial-twin-tags "{ 'tags': { 'type': 'rpi' }, 'properties': { 'desired': {} } }"  \
        --reprovision-policy reprovisionandmigratedata \
        --provisioning-status enabled

      echo "-----------------"
      echo "-- Enrollment info:"

      az iot dps enrollment-group show \
        --dps-name ${azurerm_iothub_dps.main.name} \
        --enrollment-id jetson-nano-symkey \
        --resource-group ${azurerm_resource_group.main.name}

      echo "-----------------"


      az iot dps enrollment-group show \
        --dps-name ${azurerm_iothub_dps.main.name} \
        --enrollment-id rpi-standard-symkey \
        --resource-group ${azurerm_resource_group.main.name}
    EOT
    filename = "${path.module}/../scripts/enrollment-dps-create.sh"
} */
