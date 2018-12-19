### Running Docker in Production

### Pros and Cons of running Docker in Production:

  - One one hand, many docker pioneers are confident that a
distributed web app can be deployed at scale using Docker and
have incorporated Docker into their production environment.
  - On the other hand, there are still some people who are
reluctant to use Docker in production as they think docker
workflow is too complex or unstable for real life use cases.

### Concerns

  - There are still some missing pieces about Docker around data
persistence, networking, security and identity management.
  - The ecosystem of supporting Dockerized applications in
production such as tools for monitoring and logging are still
not fully ready yet.

### Companies that use Docker in production:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/prod_docker_companies.png)

### Why Running Docker Containers inside VMs?
  - To address security concerns(separate the resource access to different customers `data`, `traffic`)
  - Hardware level isolation(want to ensure that hardware are available for all containers and there isn't any starvation situation)

### Worth nothing

  - Most popular content or management service such as Google container engine and like `Google Container enginer` or `Amazon EC2` still use VMs internally.

The simplest way to provision new VMS and containers on top up then is by using Docker Machine.
Docker Machine can provision new volume's install `dockertools` on them and link docker client with remote docker machines.
We can provision a VM on our local machine to do that. We need VirtualBox which is a virtualization technology that allows us to install multiple guest operating systems on a single machine.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/docker_machine.png)


### Install Docker machine

Instructions for Docker Machine installation available [here](https://docs.docker.com/machine/install-machine/#install-machine-directly)

```
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
>   curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
> install /tmp/docker-machine /usr/local/bin/docker-machine
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   617    0   617    0     0   1024      0 --:--:-- --:--:-- --:--:--  1024
100 26.8M  100 26.8M    0     0  1011k      0  0:00:27  0:00:27 --:--:--  857k
```

### Check Docker-machine version:

```
docker-machine -v
docker-machine version 0.16.0, build 702c267f
```
