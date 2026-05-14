# terraform.tfvars

app_name           = "mywebapp7564"
location           = "eastus"
resource_group_name = "my-resource-group"

sku_name = "B1"

os_type = "Linux"

worker_count = 1

always_on = true

application_stack = {
  python_version = "3.11"
}

app_settings = {
  ENVIRONMENT = "dev"
  SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
}

tags = {
  Environment = "Dev"
  Project     = "WebApp"
}