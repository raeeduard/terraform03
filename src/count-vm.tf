# Создание двух ВМ с использованием count
resource "yandex_compute_instance" "web" {
  count       = 2
  name        = "web-${count.index + 1}"  # Имена web-1 и web-2
  platform_id = "standard-v1"
  zone        = var.default_zone

  resources {
    cores  = 2
    memory = 2
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

 
}

# Вывод информации о созданных ВМ
output "web_instances" {
  description = "Информация о созданных виртуальных машинах"
  value = {
    for instance in yandex_compute_instance.web:
    instance.name => {
      "id"          = instance.id
      "internal_ip" = instance.network_interface.0.ip_address
      "external_ip" = instance.network_interface.0.nat_ip_address
      "fqdn"        = instance.fqdn
    }
  }
}