FROM ubuntu:14.04

USER root

RUN  apt-get update \
  && apt-get install -y wget curl \
     openssh-client jq unzip

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/0.10.8/terraform_0.10.8_linux_amd64.zip?_ga=2.212246934.322833897.1509074608-1054378191.1508520146 -O terraform.zip \
  && unzip terraform.zip \
  && mv terraform /usr/local/bin/

# Install Packer
RUN wget https://releases.hashicorp.com/packer/1.0.4/packer_1.0.4_linux_amd64.zip?_ga=2.222373275.1263275549.1503370872-1006178486.1503370872 \
  -O packer.zip \
  && unzip packer.zip \
  && mv packer /usr/local/bin/

RUN mkdir terraform \
    && mkdir packer 

COPY terraform/ /terraform

COPY packer/ /packer

COPY boot.sh /boot.sh

ENTRYPOINT ["/boot.sh"]
