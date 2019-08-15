resource "random_id" "postgres_password" {
  byte_length = 16
}

resource "random_id" "kibana_password" {
  byte_length = 16
}

resource "ibm_compute_vm_instance" "elk_node" {
  hostname             = "elk"
  domain               = "${var.domain}"
  os_reference_code    = "${var.os_reference_code["u18"]}"
  datacenter           = "${var.datacenter["us-south2"]}"
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  local_disk           = true
  user_metadata        = "${file("install.yml")}"
  flavor_key_name      = "${var.flavor_key_name["blocal-large"]}"
  tags                 = ["ryantiffany", "${var.datacenter["us-south2"]}"]
  ssh_key_ids          = ["${data.ibm_compute_ssh_key.deploymentKey.id}"]
}

resource "dnsimple_record" "elk" {
  domain = "${var.domain}"
  name   = "elk"
  value  = "${ibm_compute_vm_instance.elk_node.ipv4_address}"
  type   = "A"
  ttl    = 3600
}

resource "ibm_database" "elk_postgres" {
  name              = "elk-postgres-rt"
  plan              = "standard"
  location          = "${var.location["south"]}"
  service           = "databases-for-postgresql"
  resource_group_id = "${data.ibm_resource_group.rs_group.id}"
  tags              = ["ryantiffany", "region:${var.location["south"]}", "project:elk-icd"]
  adminpassword     = "${random_id.postgres_password.hex}"
}

resource "null_resource" "httpd-password" {
  provisioner "local-exec" {
    command = "openssl passwd -apr1 ${random_id.kibana_password.hex} | tee -a htpasswd.users"
  }
}

resource "local_file" "output" {
  content = <<EOF
[elk]
elk ansible_host=${ibm_compute_vm_instance.elk_node.ipv4_address} ansible_ssh_user=ryan

[elk:vars]
host_key_checking = False
EOF

  filename = "${path.module}/inventory.env"
}

resource "local_file" "icd_connections" {
  content = <<EOF
${jsonencode(ibm_database.elk_postgres.connectionstrings.0.hosts)}

EOF

  filename = "${path.module}/connection_strings.json"
}

output "ICD Host" {
  value = "${jsonencode(ibm_database.elk_postgres.connectionstrings.0.hosts)}"
}
