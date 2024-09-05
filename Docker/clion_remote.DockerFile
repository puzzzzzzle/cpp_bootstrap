# CLion remote docker environment (How to build docker container, run and stop it)
#
# Build and run:
# environment variable neededs：
#       export DOCKER_BUILDKIT=1
#       export COMPOSE_DOCKER_CLI_BUILD=1

#   docker build -t clion_remote:0.1 -f clion_remote.DockerFile .
#    docker run -d --cap-add sys_ptrace -v /data:/data -p 30022:22 --name cb clion_remote:0.1
#
# stop:
#   docker stop clion_remote_env
#
# ssh credentials (test user):
#   user@password

FROM clion_local:0.1


# config sshd
FROM ubuntu:20.04

RUN set -e && \
    # user
    useradd -m user && \
    yes password | passwd user && \
    usermod -s /bin/bash user && \
    \
    # sshd
    mkdir -p /var/run/sshd && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    \
    # ssh config
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "LogLevel DEBUG2" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "Subsystem sftp /usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config && \
    \
    # pam
    sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd && \
    \
    # lang
    /bin/echo -e "LANG=\"en_US.UTF-8\"" > /etc/default/locale

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
