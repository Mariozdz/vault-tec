terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = var.subscription_id
}

#--------------------------------------
# Resource group
#--------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-nebula"
  location = "westus3"
}

#--------------------------------------
# Virtual network
#--------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "nebula-vnet"
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#--------------------------------------
# Subnet
#--------------------------------------
resource "azurerm_subnet" "dmz" {
  name                 = "dmz-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.19.0/24"]
}

#--------------------------------------
# Network security group
#--------------------------------------
resource "azurerm_network_security_group" "dmz_nsg" {
  name                = "dmz-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
  name                       = "allow-nebula-udp-4242"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Udp"
  source_port_range          = "*"
  destination_port_range     = "4242"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "dmz_assoc" {
  subnet_id                 = azurerm_subnet.dmz.id
  network_security_group_id = azurerm_network_security_group.dmz_nsg.id
}

#--------------------------------------
# Public IP
#--------------------------------------
resource "azurerm_public_ip" "dmz_ip" {
  name                = "dmz-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"  
  sku                 = "Standard" 
}

#--------------------------------------
# Network Interface for VM
#--------------------------------------
resource "azurerm_network_interface" "dmz_nic" {
  name                = "dmz-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "172.16.19.10"          # IP fija dentro de DMZ
    public_ip_address_id          = azurerm_public_ip.dmz_ip.id
  }
}

#--------------------------------------
# VM Linux 
#--------------------------------------
resource "azurerm_linux_virtual_machine" "dmz_vm" {
  name                = "dmz-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"  # free-tier
  admin_username      = "azureuser"
  disable_password_authentication = true

  custom_data = filebase64("${path.module}/cloud-init.yaml")

  network_interface_ids = [
    azurerm_network_interface.dmz_nic.id
  ]

  # SSH key para acceso
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
}