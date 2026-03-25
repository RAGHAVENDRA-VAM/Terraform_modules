resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge({ Name = var.nsg_name }, var.tags)
}

resource "azurerm_network_security_rule" "this" {
  for_each = var.security_rules

  name                        = each.key
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = lookup(each.value, "source_port_range", "*")
  destination_port_range      = lookup(each.value, "destination_port_range", null)
  destination_port_ranges     = lookup(each.value, "destination_port_ranges", null)
  source_address_prefix       = lookup(each.value, "source_address_prefix", "*")
  destination_address_prefix  = lookup(each.value, "destination_address_prefix", "*")
  description                 = lookup(each.value, "description", "")
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = toset(var.subnet_ids)
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}
