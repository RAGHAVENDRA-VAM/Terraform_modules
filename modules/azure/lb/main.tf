resource "azurerm_public_ip" "this" {
  count               = var.create_public_ip ? 1 : 0
  name                = "${var.lb_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "this" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend"
    public_ip_address_id          = var.create_public_ip ? azurerm_public_ip.this[0].id : null
    subnet_id                     = var.create_public_ip ? null : var.subnet_id
    private_ip_address_allocation = var.create_public_ip ? null : (var.private_ip != null ? "Static" : "Dynamic")
    private_ip_address            = var.create_public_ip ? null : var.private_ip
  }

  tags = merge({ Name = var.lb_name }, var.tags)
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = "${var.lb_name}-backend-pool"
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "this" {
  for_each = var.probes

  name            = each.key
  loadbalancer_id = azurerm_lb.this.id
  protocol        = lookup(each.value, "protocol", "Tcp")
  port            = each.value.port
  request_path    = lookup(each.value, "request_path", null)
  interval_in_seconds = lookup(each.value, "interval", 15)
  number_of_probes    = lookup(each.value, "number_of_probes", 2)
}

resource "azurerm_lb_rule" "this" {
  for_each = var.lb_rules

  name                           = each.key
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = lookup(each.value, "probe_name", null) != null ? azurerm_lb_probe.this[each.value.probe_name].id : null
  enable_floating_ip             = lookup(each.value, "enable_floating_ip", false)
  idle_timeout_in_minutes        = lookup(each.value, "idle_timeout", 4)
  load_distribution              = lookup(each.value, "load_distribution", "Default")
}

resource "azurerm_lb_nat_rule" "this" {
  for_each = var.nat_rules

  name                           = each.key
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = "frontend"
}
