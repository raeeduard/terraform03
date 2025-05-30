resource "yandex_compute_disk" "additional_disks" {
  count     = 3
  name      = "additional-disk-${count.index}"
  size      = 1 
  zone      = var.default_zone
  type      = "network-hdd"
}


resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v1"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 4
  }

boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2004.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.additional_disks
    content {
      disk_id = secondary_disk.value.id
    }
  }

 
}

output "storage_vm_info" {
  description = "Информация о ВМ storage и подключенных дисках"
  value = {
    vm_name = yandex_compute_instance.storage.name
    vm_id   = yandex_compute_instance.storage.id
    disks   = [
      for disk in yandex_compute_disk.additional_disks : {
        disk_name = disk.name
        disk_id   = disk.id
        disk_size = "${disk.size} GB"
      }
    ]
  }
}