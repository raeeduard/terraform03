resource "local_file" "dynamic_inventory" {
  content = templatefile("${path.module}/inventory.tftpl",
    {
      web_servers     = yandex_compute_instance.web[*] # Используем splat expression для списка
      database_servers = values(yandex_compute_instance.db_vms) # for_each создает map
      storage_servers = [yandex_compute_instance.storage]
    }
  )
  filename = "${abspath(path.module)}/inventory.ini"
}