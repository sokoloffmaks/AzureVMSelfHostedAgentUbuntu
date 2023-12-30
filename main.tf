provider "azurerm" {
  features {}
  #subscription_id = "ae349be3-7ce1-4249-87bb-99b82ecf8594"
}

resource "azurerm_resource_group" "rg" {
  name     = "arg-aus-sha-01"
  location = "Australia East"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "VPNVirtualNetwork-sha"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "VPNSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.100.0/24"]
}

resource "azurerm_public_ip" "vpn_public_ip" {
  name                = "sha-ubuntu-nic-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "vm_public_ip" {
  description = "The public IP of the VM"
  value       = azurerm_public_ip.vpn_public_ip.ip_address
}

resource "azurerm_network_interface" "nic" {
  name                = "sha-ubuntu-nic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vpn_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.vpn_nsg.id
}


resource "azurerm_network_security_group" "vpn_nsg" {
  name                = "sha-ubuntu-01-NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "OpenVPN"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  // If you want to add the default rule for SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Monitor"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5555"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Admin"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "943"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "vm-sha-01"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("c:/openvpn/mykey.pub")
  }
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "remote-exec" {
    inline = [
      "wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb",
      "sudo dpkg -i packages-microsoft-prod.deb",
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https dotnet-sdk-6.0 git",
      "wget https://raw.github.com/Nyr/openvpn-install/master/openvpn-install.sh -O openvpn-install.sh",
      "chmod +x openvpn-install.sh",
      "sed -i 's|^IP=.*$|IP=$(wget -qO- https://ipecho.net/plain)|' openvpn-install.sh",
      "sed -i 's|^PORT=.*$|PORT=443|' openvpn-install.sh",
      "sed -i 's|^PROTOCOL=.*$|PROTOCOL=tcp|' openvpn-install.sh",
      "sed -i 's|^DNS=.*$|DNS=4|' openvpn-install.sh",
      "sed -i '/read -p \".*protocol.*\"/d' openvpn-install.sh",
      "sed -i '/read -p \".*port.*\"/d' openvpn-install.sh",
      "sed -i '/read -p \".*DNS.*\"/d' openvpn-install.sh",
      "sed -i '/read -p \".*name.*\"/d' openvpn-install.sh",
      "echo 'clientname' | sudo ./openvpn-install.sh",
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",
      "curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -",
      "curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list",
      "sudo apt-get update",
      "sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev",
      "echo 'export PATH=\"$PATH:/opt/mssql-tools/bin\"' >> ~/.bashrc",
      "source ~/.bashrc",
      "wget https://vstsagentpackage.azureedge.net/agent/3.232.1/vsts-agent-linux-x64-3.232.1.tar.gz",
      "mkdir myagent && cd myagent",
      "tar zxvf ../vsts-agent-linux-x64-3.232.1.tar.gz",
      "echo Y | ./config.sh --url https://dev.azure.com/wvdlabs --auth pat --token *insert_your_PAT_here* --pool "insert_your_azdo_pool_here" --agent $(hostname) --replace",
      "sudo ./svc.sh install",
      "sudo ./svc.sh start"
    ]
  }

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.vpn_public_ip.ip_address
    user        = "adminuser"
    private_key = file("c:/openvpn/mykey")
  }
}
