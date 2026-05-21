# 1. Resource Group (No tags - Simulation of bad practice)
resource "azurerm_resource_group" "legacy_rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2. Network Setup
resource "azurerm_virtual_network" "legacy_vnet" {
  name                = "vnet-appx-legacy"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.legacy_rg.location
  resource_group_name = azurerm_resource_group.legacy_rg.name
}

resource "azurerm_subnet" "legacy_subnet" {
  name                 = "sub-default"
  resource_group_name  = azurerm_resource_group.legacy_rg.name
  virtual_network_name = azurerm_virtual_network.legacy_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "legacy_nic" {
  name                = "nic-dev-vm"
  location            = azurerm_resource_group.legacy_rg.location
  resource_group_name = azurerm_resource_group.legacy_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.legacy_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 3. WASTE FULL DEV VM (Running 24x7 with premium storage)
resource "azurerm_linux_virtual_machine" "wasteful_vm" {
  name                            = "vm-appx-dev-01"
  resource_group_name             = azurerm_resource_group.legacy_rg.name
  location                        = azurerm_resource_group.legacy_rg.location
  size                            = "Standard_DC1ds_v3" # Over-provisioned for dev workload
  admin_username                  = "azureuser"
  admin_password                  = "Password12345!"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.legacy_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS" # Costly storage for non-prod environment
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

# 4. ZOMBIE RESOURCE 1: Orphaned Managed Disk
resource "azurerm_managed_disk" "orphaned_disk" {
  name                 = "disk-appx-backup-old"
  location             = azurerm_resource_group.legacy_rg.location
  resource_group_name  = azurerm_resource_group.legacy_rg.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 64 # Unattached but costing money
}

# 5. ZOMBIE RESOURCE 2: Unassociated Public IP
resource "azurerm_public_ip" "orphaned_ip" {
  name                = "pip-appx-unused"
  location            = azurerm_resource_group.legacy_rg.location
  resource_group_name = azurerm_resource_group.legacy_rg.name
  allocation_method   = "Static"
  sku                 = "Standard" # Charges apply even if idle
}