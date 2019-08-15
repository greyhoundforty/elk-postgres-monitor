data "ibm_compute_ssh_key" "deploymentKey" {
  label = "ryan_tycho"
}

data "ibm_resource_group" "rs_group" {
  name = "CDE"
}

data "template_file" "log-psg" {
  template = "${file("${path.cwd}/Templates/postgresql.conf.tpl")}"

  vars {
    psg_password = "${random_id.postgres_password.hex}"
    port         = "${ibm_database.elk_postgres.connectionstrings.0.hosts.0.port}"
    host         = "${ibm_database.elk_postgres.connectionstrings.0.hosts.0.host}"
  }
}
