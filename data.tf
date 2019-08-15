data "ibm_compute_ssh_key" "deploymentKey" {
  label = "ryan_tycho"
}

data "ibm_resource_group" "rs_group" {
  name = "CDE"
}
