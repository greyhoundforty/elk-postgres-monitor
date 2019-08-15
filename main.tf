data "ibm_compute_ssh_key" "deploymentKey" {
  label = "ryan_tycho"
}

data "ibm_resource_group" "rs_group" {
  name = "CDE"
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
}

resource "ibm_service_key" "elk_postgress_creds" {
  name                  = "elk-postgres-rt-creds"
  service_instance_guid = "${ibm_database.elk_postgres.id}"
}

output "ICD Etcd database connection string" {
  value = "http://${"${ibm_database.elk_postgres.connectionstrings.0.composed}"}"
}