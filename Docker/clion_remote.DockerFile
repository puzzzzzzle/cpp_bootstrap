# syntax = edrevo/dockerfile-plus

# CLion remote docker environment (How to build docker container, run and stop it)
#
# Build and run:
# environment variable neededs：
#       export DOCKER_BUILDKIT=1
#       export COMPOSE_DOCKER_CLI_BUILD=1

#   docker build -t puzzzzzzle/clion_remote:0.6.1 -f clion_remote.DockerFile .
#    docker run -d --cap-add sys_ptrace -v /data:/host_data -p 30022:22 --name cb puzzzzzzle/clion_remote:0.6.1
#
# stop:
#   docker stop clion_remote_env
#
# ssh credentials (test user):
#   user@password

FROM ubuntu:22.04

INCLUDE+ base_libs.DockerFile

# config sshd
RUN <<EOT
set -e
# user
useradd -m user \
  && yes password | passwd user \
  && usermod -s /bin/bash user

# sshd
mkdir -p /var/run/sshd
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key

# ssh config
echo >> /etc/ssh/sshd_config <<EOL
PermitRootLogin yes
LogLevel DEBUG2
PermitRootLogin yes
PasswordAuthentication yes
Subsystem sftp /usr/lib/openssh/sftp-server
EOL

# pam
sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd

# lang
/bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/local

EOT

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
