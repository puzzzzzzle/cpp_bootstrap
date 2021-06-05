 # build docker
 docker build -t clion/ubuntu_dev -f Dockefile.default .
 # create
 docker run -d --cap-add sys_ptrace -p 127.0.0.1:2233:22 -v /g/projects:/data/projects --name clion_ubuntu clion/ubuntu_dev