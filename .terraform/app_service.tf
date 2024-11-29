terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rsg-laravel-ci-cd-example"
}

variable "location" {
  description = "The location of the resources"
  type        = string
  default     = "UK South"
}

variable "app_service_name" {
  description = "The name of the App Service"
  type        = string
  default     = "app_laravel_ci_cd_example"
}

variable "mysql_server_name" {
  description = "The name of the MySQL server"
  type        = string
  default     = "db_laravel_ci_cd_example"
}

variable "mysql_database_name" {
  description = "The name of the MySQL database"
  type        = string
  default     = "laravel"
}

variable "mysql_admin_username" {
  description = "The administrator username for MySQL"
  type        = string
  default     = "app_root"
}

variable "mysql_admin_password" {
  description = "The administrator password for MySQL"
  type        = string
  sensitive   = true
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# MySQL Server
resource "azurerm_mysql_flexible_server" "main" {
  name                = var.mysql_server_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_name            = "Standard_B1ms"
  administrator_login = var.mysql_admin_username
  administrator_password = var.mysql_admin_password
  version = "8.0"
  delegated_subnet_id = null
}

# MySQL Database
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.mysql_database_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset   = "utf8mb4"
  collation = "utf8mb4_general_ci"
}

# App Service Plan
resource "azurerm_app_service_plan" "main" {
  name                = "${var.app_service_name}-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

# App Service
resource "azurerm_app_service" "main" {
  name                = var.app_service_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.main.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "MYSQL_HOST"               = azurerm_mysql_flexible_server.main.fqdn
    "MYSQL_DATABASE"           = azurerm_mysql_flexible_database.main.name
    "MYSQL_USERNAME"           = azurerm_mysql_flexible_server.main.administrator_login
    "MYSQL_PASSWORD"           = var.mysql_admin_password
  }
}

output "app_service_url" {
  value = azurerm_app_service.main.default_site_hostname
}

output "mysql_server_fqdn" {
  value = azurerm_mysql_flexible_server.main.fqdn
}
