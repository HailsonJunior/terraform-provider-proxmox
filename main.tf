terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "2.7.4"
        }
    }
}

provider "proxmox" {
    pm_api_url = "https://10.1.1.14:8006/api2/json" 
    pm_api_token_id = "terraform@pam!token_id" 
    pm_api_token_secret = "YOUR-SECRET-TOKEN"
    pm_tls_insecure = true 
}

resource "proxmox_vm_qemu" "test_server" {
    count = 1 
    name = "teste-vm-terraform"
    target_node = var.proxmox_host
    clone = var.template_name

    agent = 1
    os_type = "cloud-init"
    cores = 2
    sockets = 1
    cpu = "host"
    memory = "2048"
    scsihw = "virtio-scsi-pci"
    bootdisk = "scsi0"

    disk {
        slot = 0
        size = "10G"
        type = "scsi"
        storage = "str-1-hmlg-a-infra"
        iothread = 1
    }

    network {
        model = "virtio"
        bridge = "vmbr5"
    }

    lifecycle {
        ignore_changes = [
            network,
        ]
    }

    ipconfig0 = "ip=192.168.1.10/24,gw=192.168.1.1"

    sshkeys = <<EOF
    ${var.ssh_key}
    EOF
}