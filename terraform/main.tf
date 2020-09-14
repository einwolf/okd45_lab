terraform {
  required_version = ">= 0.13"
  required_providers {
    vsphere = {
      version = "~> 1.24"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "IonDC"
}

data "vsphere_datastore" "datastore" {
  name          = "stovault-nfs-eco4-vms1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "IonCluster1/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "mgmt_dpg1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "okd4-bootstrap" {
  name             = "okd4-bootstrap"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  firmware = "efi"
  num_cpus = 4
  memory   = 16384
  guest_id = "fedora64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 120
    thin_provisioned = "true"
  }
}

resource "vsphere_virtual_machine" "okd4-services" {
  name             = "okd4-services"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  firmware = "efi"
  num_cpus = 4
  memory   = 16384
  guest_id = "fedora64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 120
    thin_provisioned = "true"
  }
}

resource "vsphere_virtual_machine" "okd4-pfsense" {
  name             = "okd4-pfsense"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  firmware = "efi"
  num_cpus = 1
  memory   = 1024
  guest_id = "freebsd64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 8
    thin_provisioned = "true"
  }
}
