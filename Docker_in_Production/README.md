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

### Setup a production cloud account

We register a [DigitalOcean account](https://www.digitalocean.com/) so we can deploy our app. Digital Ocean is a cloud infrastructure provider that can easily provision virtual servers for you.It is similar to AWS EC2 and we can use it to deploy, manage, and scale cloud applications.

We use API's to manage, use the resources and provision VMs
In API section we generate an access token. We use the access token to create e new VM on DigitalOcean, installing docker, create certificates.

### Create docker-app-machine on digitalocean


```
docker-machine create --driver digitalocean --help
Usage: docker-machine create [OPTIONS] [arg...]

Create a machine

Description:
   Run 'docker-machine create --driver name --help' to include the create flags for that driver in the help text.

Options:

   --digitalocean-access-token 										Digital Ocean access token [$DIGITALOCEAN_ACCESS_TOKEN]
 ```

 ```
 docker-machine create --driver digitalocean --digitalocean-access-token `token_setup_previously` docker-app-machine

 Creating CA: /root/.docker/machine/certs/ca.pem
Creating client certificate: /root/.docker/machine/certs/cert.pem
Running pre-create checks...
Creating machine...
(docker-app-machine) Creating SSH key...
(docker-app-machine) Creating Digital Ocean droplet...
(docker-app-machine) Waiting for IP address to be assigned to the Droplet...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with ubuntu(systemd)...
Installing Docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: docker-machine env docker-app-machine
```

### Connection informations:

docker-machine env docker-app-machine
```
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://ip_addr:port"
export DOCKER_CERT_PATH="/root/.docker/machine/machines/docker-app-machine"
export DOCKER_MACHINE_NAME="docker-app-machine"
# Run this command to configure your shell:
# eval $(docker-machine env docker-app-machine)
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/docker_app_digital_ocean.png)

Run the environment variables which would configure our doctor client to connect to the VM which is provisioned

```eval $(docker-machine env docker-app-machine)
```

Display the system wide information about the new VM:

```
docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
------------------------------------------------------------------------------------------------------------
Operating System: Ubuntu 16.04.5 LTS
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 992.2MiB
Name: docker-app-machine
------------------------------------------------------------------------------------------------------------
Labels:
 provider=digitalocean
Experimental: false
```

Digital Ocean VM | Specs
-|-
OS | Ubuntu 16.04.5 LTS
Architecture | x86_64
CPU  | 1  
Memory  |  992.2 Mib

Finally we need to deploy our docker container. We use the app image that passed all the tests in `Circle CI` and pushed to `DockerHub`.
Instead of rebuilding the image using Dockerfile locally we make a copy of the compose file and edit it.
We remove the build section from prod.yml and put the latest image from our DockerHub account:

```
version: "3.0"
services:
  dockerapp:
    image: praslea/dockerapp
    ports:
      - "5000:5000"
    depends_on:
      - redis
  redis:
    image: redis:3.2.0
```


With `-f` switch we put our new docker-compose file then `-d` to started the containers in the background.
This would deploy all the services defined in compose file to the remote VM.

docker-compose -f prod.yml up -d
```
Creating network "dockerapp_default" with the default driver
Pulling redis (redis:3.2.0)...
3.2.0: Pulling from library/redis
------------------------------------------------------------------------------------------------------------
Pulling dockerapp (praslea/dockerapp:)...
latest: Pulling from praslea/dockerapp
------------------------------------------------------------------------------------------------------------
Creating dockerapp_redis_1_f58637094be9 ... done
Creating dockerapp_dockerapp_1_6ae529f9cf79 ... done
```

We verify that docker machine is up and running:

docker-machine ls
```
NAME                 ACTIVE   DRIVER         STATE     URL                        SWARM   DOCKER     ERRORS
docker-app-machine   *        digitalocean   Running   tcp://ip:port           v18.09.0   
```

`*` -- specifies that this docker-machine is active and all the changes we make will be done on this particular machine.

### Verify dockerapp in DigitalOcean:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/docker_app_machine.png)


There are several `digitalocean` drives we can use `--help` switch or [this link](https://docs.docker.com/machine/drivers/digital-ocean/)

docker-machine create --driver digitalocean --help
Usage: docker-machine create [OPTIONS] [arg...]

Create a machine

Description:
   Run 'docker-machine create --driver name --help' to include the create flags for that driver in the help text.

Options | Description
-|-
   --digitalocean-access-token | Digital Ocean access token [$DIGITALOCEAN_ACCESS_TOKEN]
    --digitalocean-backups | enable backups for droplet [$DIGITALOCEAN_BACKUPS]
   --digitalocean-image "ubuntu-16-04-x64" | Digital Ocean Image [$DIGITALOCEAN_IMAGE]
   --digitalocean-ipv6 | enable ipv6 for droplet [$DIGITALOCEAN_IPV6]
   --digitalocean-monitoring | enable monitoring for droplet [$DIGITALOCEAN_MONITORING]
   --digitalocean-private-networking | enable private networking for droplet [$DIGITALOCEAN_PRIVATE_NETWORKING]
   --digitalocean-region "nyc3" | Digital Ocean region [$DIGITALOCEAN_REGION]
   --digitalocean-size "s-1vcpu-1gb" | Digital Ocean size [$DIGITALOCEAN_SIZE]
   --digitalocean-ssh-key-fingerprint | SSH key fingerprint [$DIGITALOCEAN_SSH_KEY_FINGERPRINT]
   --digitalocean-ssh-key-path | SSH private key path  [$DIGITALOCEAN_SSH_KEY_PATH]
   --digitalocean-ssh-port "22"	| SSH port [$DIGITALOCEAN_SSH_PORT]
   --digitalocean-ssh-user "root"	| SSH username [$DIGITALOCEAN_SSH_USER]
   --digitalocean-tags | comma-separated list of tags to apply to the Droplet [$DIGITALOCEAN_TAGS]
   --digitalocean-userdata | path to file with cloud-init user-data [$DIGITALOCEAN_USERDATA]
   --driver, -d "virtualbox" | Driver to create machine with. [$MACHINE_DRIVER]
   --engine-env [--engine-env option --engine-env option]	| Specify environment variables to set in the engine
   --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option] | 	Specify insecure registries to allow with the created engine
   --engine-install-url "https://get.docker.com" | Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]
   --engine-label [--engine-label option --engine-label option]	| Specify labels for the created engine
   --engine-opt [--engine-opt option --engine-opt option]	| Specify arbitrary flags to include with the created engine in the form flag=value
   --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option] | Specify registry mirrors to use [$ENGINE_REGISTRY_MIRROR]
   --engine-storage-driver | Specify a storage driver to use with the engine
   --swarm | Configure Machine to join a Swarm cluster
   --swarm-addr | addr to advertise for Swarm (default: detect and use the machine IP)
   --swarm-discovery | Discovery service to use with Swarm
   --swarm-experimental | Enable Swarm experimental features
   --swarm-host "tcp://0.0.0.0:3376" | ip/socket to listen on for Swarm master
   --swarm-image "swarm:latest"	| Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]
   --swarm-join-opt [--swarm-join-opt option --swarm-join-opt option] | Define arbitrary flags for Swarm join
   --swarm-master	| Configure Machine to be a Swarm master
   --swarm-opt [--swarm-opt option --swarm-opt option] | Define arbitrary flags for Swarm master
   --swarm-strategy "spread" | Define a default scheduling strategy for Swarm
   --tls-san [--tls-san option --tls-san option] | Support extra SANs for TLS certs


### Scale Docker for large applications

A swarm is a group of machines that are running Docker and joined into a cluster. After that has happened, you continue to run the Docker commands you’re used to, but now they are executed on a cluster by a swarm manager. The machines in a swarm can be physical or virtual. After joining a swarm, they are referred to as nodes.
This is what Docker Swarm is for:

  - Docker Swarm is a tool that clusters many Docker Engines and schedules Containers
  - Docker Swarm decides on which host to run the container based on scheduling methods

Docker Swarm manages remote hosts in the cloud running docker daemon. Swarm manager knows the status of each Docker Node in the cluster.Swarm can grow multiple hosts into a cluster and distribute dcoker containers among these hosts. So the work load is divided by the nodes in the swarm and this is transparent to the end users.
The workload is outsourced from the client to swarm manager

![IMG](images/docker_swarm.jpeg)
