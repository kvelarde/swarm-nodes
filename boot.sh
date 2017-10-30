#!/bin/sh

# Log File
LOGFILE="swarm-build.log"

# Pull consul ENV variables
SERVICE_ENDPOINT="http://34.214.176.16:8500/v1/kv/sandbox"

get_url () { curl --silent ${SERVICE_ENDPOINT} | jq -r '.[] | .Value' | base64 -d | jq -r 'to_entries[] | "export \(.key)=\(.value)"'; }

IFS=^M; for i in $(get_url); do eval $i; done; unset IFS

# Array for base SSH options.
SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /keys/${TF_VAR_key_name}.pem"


cd packer
#packer build -machine-readable -var "packer_builder_security_group=${PACKER_sec_group_id}"  -var "subnet_id=${PACKER_subnet_id}" packer-ubuntu-docker.json | \
#    /usr/bin/tee packer-ubuntu-docker.log
#
#AMI=$(echo $(tail -n1 packer-ubuntu-docker.log | cut -d":" -f4))
AMI="ami-ca8e46b2"

cd ..

cd terraform

terraform init

terraform apply -target aws_instance.swarm-manager -var swarm_init=true -var "swarm_ami_id=${AMI}" -var swarm_managers=1 \
        && export TF_VAR_swarm_manager_token=$(ssh ${SSHOPTS} ubuntu@$(terraform output swarm_manager_1_public_ip) \
            docker swarm join-token -q manager) \
        && export TF_VAR_swarm_worker_token=$(ssh ${SSHOPTS} ubuntu@$(terraform output swarm_manager_1_public_ip) \
            docker swarm join-token -q worker) \
        && export TF_VAR_swarm_manager_ip=$(terraform output swarm_manager_1_private_ip) \
        && terraform apply -var "swarm_ami_id=${AMI}" | tee ${LOGFILE}
