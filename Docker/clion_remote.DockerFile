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

RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd

RUN useradd -m user \
  && yes password | passwd user \
  && usermod -s /bin/bash user

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]