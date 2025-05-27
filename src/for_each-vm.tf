# Определение переменной (можно вынести в variables.tf)
variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    disk_volume = number
  }))
  default = [
    {
      vm_name     = "main"
      cpu         = 4
      ram         = 8
      disk_volume = 50
    },
    {
      vm_name     = "replica"
      cpu         = 2
      ram         = 4
      disk_volume = 30
    }
  ]
}

# Создание ВМ с использованием for_each
resource "yandex_compute_instance" "db_vms" {
  for_each    = { for vm in var.each_vm : vm.vm_name => vm }
  name        = each.value.vm_name
  platform_id = "standard-v1"
  zone        = var.default_zone

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
  }

  boot_disk {
    initialize_params {
      image_id = "fd81hgrcv6lsnkremf32" # Ubuntu 20.04 LTS
      size     = each.value.disk_volume
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.example.id]
  }


}

# Вывод информации о созданных ВМ
output "db_instances" {
  description = "Информация о ВМ баз данных"
  value = {
    for vm_name, instance in yandex_compute_instance.db_vms :
    vm_name => {
      "id"          = instance.id
      "internal_ip" = instance.network_interface.0.ip_address
      "external_ip" = instance.network_interface.0.nat_ip_address
      "fqdn"        = instance.fqdn
      "cpu"         = instance.resources[0].cores
      "ram"         = instance.resources[0].memory
      "disk_size"   = instance.boot_disk[0].initialize_params[0].size
    }
  }
}