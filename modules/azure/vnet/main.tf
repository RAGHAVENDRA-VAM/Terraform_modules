resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = merge({ Name = var.vnet_name }, var.tags)
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = lookup(delegation.value, "actions", [])
      }
    }
  }

  service_endpoints = lookup(each.value, "service_endpoints", [])
}

resource "azurerm_network_security_group" "this" {
  for_each            = { for k, v in var.subnets : k => v if lookup(v, "create_nsg", false) }
  name                = "${each.key}-nsg"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = { for k, v in var.subnets : k => v if lookup(v, "create_nsg", false) }
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_nat_gateway" "this" {
  count               = var.create_nat_gateway ? 1 : 0
  name                = "${var.vnet_name}-nat-gw"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "nat" {
  count               = var.create_nat_gateway ? 1 : 0
  name                = "${var.vnet_name}-nat-pip"
  location            = var.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count                = var.create_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}
