#!/bin/sh

# Log File
LOGFILE="swarm-build.log"

# Array for base SSH options.
SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /keys/${TF_VAR_key_name}.pem"

# Pull consul ENV variables
SERVICE_ENDPOINT_ENV="http://34.214.176.16:8500/v1/kv/sandbox"
SERVICE_ENDPOINT_AMI="http://34.214.176.16:8500/v1/kv/env/aws/sandbox/ami"

get_env () { 
	curl --silent ${SERVICE_ENDPOINT_ENV} | jq -r '.[] | .Value' | base64 -d | jq -r 'to_entries[] | "export \(.key)=\(.value)"'
}

get_img () { 
        curl --silent ${SERVICE_ENDPOINT_AMI} | jq -r '.[] | .Value' | base64 -d | jq -r 'to_entries[] | "export \(.key)=\(.value)"'
}

IFS=^M; for i in $(get_env); do eval $i; done; unset IFS
IFS=^M; for i in $(get_img); do eval $i; done; unset IFS

SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /keys/${TF_VAR_key_name}.pem"

packer_build () {
	
	cd packer

	packer build -machine-readable -var "packer_builder_security_group=${PACKER_sec_group_id}"  -var "subnet_id=${PACKER_subnet_id}" packer-ubuntu-docker.json | /usr/bin/tee packer-ubuntu-docker.log 

	AMI=$(echo $(tail -n1 packer-ubuntu-docker.log | cut -d":" -f4))
	curl --silent ${SERVICE_ENDPOINT_AMI} --request PUT --data "{\"TF_VAR_swarm_ami_id\": \"$AMI\"}"
}

terraform_build () {
	cd terraform
	terraform init
	terraform apply -target aws_instance.swarm-manager -var swarm_init=true -var swarm_managers=1 \
	        && export TF_VAR_swarm_manager_token=$(ssh ${SSHOPTS} ubuntu@$(terraform output swarm_manager_1_public_ip) \
	            docker swarm join-token -q manager) \
	        && export TF_VAR_swarm_worker_token=$(ssh ${SSHOPTS} ubuntu@$(terraform output swarm_manager_1_public_ip) \
	            docker swarm join-token -q worker) \
	        && export TF_VAR_swarm_manager_ip=$(terraform output swarm_manager_1_private_ip) \
	        && terraform apply | tee ${LOGFILE}
}
terraform_destroy () {
	cd terraform
	terraform init
	terraform destroy -force
}

IFS=^M; for i in $(get_env); do eval $i; done; unset IFS
IFS=^M; for i in $(get_img); do eval $i; done; unset IFS

if [ "$1" = 'build' ]; then
	packer_build
	shift
elif [ "$1" = 'apply' ]; then
	terraform_build
	shift
elif [ "$1" = 'destroy' ]; then
	terraform_destroy
	shift
fi
