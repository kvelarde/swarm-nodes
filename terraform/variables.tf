variable "swarm_manager_token" {
  default = ""
}
variable "swarm_worker_token" {
  default = ""
}
variable "swarm_ami_id" {
  default = ""
}
variable "swarm_manager_ip" {
  default = ""
}
variable "swarm_managers" {
  default = 1
}
variable "swarm_workers" {
  default = 2
}

variable "swarm_workers_log" {
  default = 2
}

variable "key_name" {
  default = ""
}

variable "swarm_instance_log_type" {
  default = "m4.2xlarge"
}
variable "swarm_instance_type" {
  default = "m4.2xlarge"
}
variable "swarm_init" {
  default = false
}

variable "subnet_id0" {
  default = ""
}

variable "sec_group_id" {
  default = ""
}
