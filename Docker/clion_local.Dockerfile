# syntax = edrevo/dockerfile-plus

# Build and run:
# environment variable neededs：
#       export DOCKER_BUILDKIT=1
#       export COMPOSE_DOCKER_CLI_BUILD=1
#   docker build -t puzzzzzzle/clion_local:0.1 -f clion_local.Dockerfile .
#   docker run -it --name cb -v /home/tao:/home/tao puzzzzzzle/clion_local:0.8.4 /bin/bash
#   docker start -ia cb
FROM ubuntu:22.04

INCLUDE+ base_libs.DockerFile
