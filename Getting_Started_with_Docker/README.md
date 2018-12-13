### Getting started with Docker

### Bare bone installation
Before virtualization an application was deployed on single hardware.
This approach had several downfalls:
  - application was not used to the full capabilities
  - if we wanted to scale up new hardware had to be purchased
  - slow deployment
  - hard to migrate from one vendor to another as we had to consider dependencies
  - big costs


![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/pre_virtualization.png)

### Hypervisor virtualization
To address this limitation Hypervisor-based Virtualization was introduced.
Each application was deployed within a Virtual Machine(VM) with it's own operation system(OS), memory, CPU, storage etc.
Still each application had to have it's own kernel. While this approach was
better it still had some limitations as it lacked full portability.

Benefits:
  - cost efficient
  - Easy to scale

Limitations:
  - Kernel Resource Duplication
  - Application Portability Issue

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/hypervisor.png)

### Container based Virtualization

Container based virtualization addresses the hypervisor based virtualization. This type of virtualization introduces another abstract level,
The Container Engine level. In Hypervisor mode virtualization happens at hardware level, and for the container based, the virtualization happens at OS level.
One kernel will be used among different containers.
Within a container only the specific application binaries/libraries will be used, no extra software, no OS.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/hyper_vs_container.png)

### Docker
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/container_virt.png)

### Docker Client-Server architecture

Docker uses a client-server architecture. We use docker client to interact with docker daemon and create/build/operate containers/images.
Docker daemon does the heavy lifting building, running, and distributing your Docker containers. Docker daemon is often referred as Docker engine or Docker server.
In terms of clients we can either user Linux shell based on various guys.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/client_server.png)


### Docker concepts

Images:
  - Images are read only templates used to create containers.
  - Images are created with the docker build command, either
by us or by other docker users.
  - Images are composed of layers of other images.
  - Images are stored in a Docker registry.

Containers:
  - If an image is a class, then a container is an instance of a
class - a runtime object.
  - Containers are lightweight and portable encapsulations of
an environment in which to run applications.
  - Containers are created from images. Inside a container, it
has all the binaries and dependencies needed to run the
application.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/images_containers.jpg)

Registries and Repositories:
  - A registry is where we store our images.
  - You can host your own registry, or you can use Docker’s
public registry which is called `DockerHub`.
  - Inside a registry, images are stored in repositories.
  - Docker repository is a collection of different docker images
with the same name, that have different tags, each tag
usually represents a different version of the image.

### Running first containers

To setup a container we use docker run command. Docker will try to search for the create a container based on the local image, if not
it will try to fetch the image from [Docker_Hub](https://hub.docker.com/)
Because it's lightweight(1-5 Mb) we will [BusyBox](https://hub.docker.com/_/busybox/)

```
docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
dabian/debian4-nodejs   latest              9604e1232028        4 weeks ago         175MB
nodejs/v1               latest              9604e1232028        4 weeks ago         175MB
debian                  latest              be2868bebaba        7 weeks ago         101MB
elasticsearch           latest              5acf0e8da90b        2 months ago        486MB
hello-world             latest              2cb0d9787c4d        5 months ago        1.85kB
portainer/portainer     latest              7afb7abcfe5f        5 months ago        57MB
continuumio/anaconda3   latest              a9090db7be5a        6 months ago        3.6GB
```

Get busybox:

```
docker run busybox:1.24
Unable to find image 'busybox:1.24' locally
1.24: Pulling from library/busybox
385e281300cc: Pull complete
a3ed95caeb02: Pull complete
Digest: sha256:8ea3273d79b47a8b6d018be398c17590a4b5ec604515f416c5b797db9dde3ad8
Status: Downloaded newer image for busybox:1.24
-------------------------------------------------------------------------------------------
docker images
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
busybox                 1.24                47bcc53f74dc        2 years ago         1.11MB
```

Running a docker command in a container is straight forward, we just need to add the `cmd` after docker run.
For instance echoing "Hello World" in busybox would be:

```
docker run busybox:1.24 echo "Hello World"
Hello World
```

Docker Switches | Explanation
-|-
-i  | will start an interactive container.   
-t  | create a pseudo-TTY that attaches standard input and output.


```
docker run -i -t busybox:1.24
/ # ls -ltr
total 36
drwxrwxrwt    2 root     root          4096 Mar 18  2016 tmp
drwxr-xr-x    2 nobody   nogroup       4096 Mar 18  2016 home
drwxr-xr-x    4 root     root          4096 Mar 18  2016 var
drwxr-xr-x    3 root     root          4096 Mar 18  2016 usr
drwxr-xr-x    2 root     root         12288 Mar 18  2016 bin
drwxr-xr-x    1 root     root          4096 Dec  9 20:13 etc
dr-xr-xr-x   13 root     root             0 Dec  9 20:13 sys
dr-xr-xr-x  249 root     root             0 Dec  9 20:13 proc
drwxr-xr-x    5 root     root           360 Dec  9 20:13 dev
drwxr-xr-x    1 root     root          4096 Dec  9 20:14 root
/ # touch test.txt
/ # ls -ltr | tail -2
drwxr-xr-x    1 root     root          4096 Dec  9 20:14 root
-rw-r--r--    1 root     root             0 Dec  9 20:15 test.txt
/ #
```

Docker can run in foreground or background.
  - Foreground: Docker run starts the process in the container and attaches the console to the process’s
standard input, output, and standard error.
  - Containers started in detached mode and exit when the root process used to run the container exits.
this can be specified with `-d` option.

If docker is started in foreground the console can't be used for other commands.

Check docker running in background by using `sleep 1000`(sleep for 1000 seconds) command and verify running containers with `ps`.

```
docker run -d busybox:1.24 sleep 1000
54198bf797935a35e3379a201834f307657e08e34f6dd4ef51022773990db326 <--------------long container id

docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                                              NAMES
54198bf79793        busybox:1.24           "sleep 1000"             3 seconds ago       Up 3 seconds                                                           unruffled_pike
```

First line has the shorthand container id, and we also got confirmation that docker is running.
If we want to list all the container including the ones that are not running at the moment we issue:

```
docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
54198bf79793        busybox:1.24            "sleep 1000"             2 minutes ago       Up 2 minutes                                                                  unruffled_pike
9e41cc1c0ce3        busybox:1.24            "sh"                     7 hours ago         Exited (0) 6 hours ago                                                        sad_yonath
700684301a2c        busybox:1.24            "-i -t"                  7 hours ago         Created                                                                       friendly_mclean
6c3f47b3e437        busybox:1.24            "echo 'Hello World'"     7 hours ago         Exited (0) 7 hours ago                                                        recursing_pascal
56de5f0d2708        busybox:1.24            "sh"                     7 hours ago         Exited (0) 7 hours ago                                                        awesome_sanderson
```

The first 5 containers are busybox, and we can see those where the commands we ran.
By default when we run docker if we don't specify the container name a new container instance will spawn.

We can remove container with `rm`:

```      
docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
54198bf79793        busybox:1.24            "sleep 1000"             10 minutes ago      Up 10 minutes                                                                 unruffled_pike
700684301a2c        busybox:1.24            "-i -t"                  7 hours ago         Created                                                                       friendly_mclean
6c3f47b3e437        busybox:1.24            "echo 'Hello World'"     7 hours ago         Exited (0) 7 hours ago                                                        recursing_pascal

docker rm recursing_pascal
recursing_pascal

docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
54198bf79793        busybox:1.24            "sleep 1000"             11 minutes ago      Up 11 minutes                                                                 unruffled_pike
700684301a2c        busybox:1.24            "-i -t"                  7 hours ago         Created                                                                       friendly_mclean
```

Or there is an option to remove container after the command has been executed

```
docker run  --rm busybox:1.24 echo "This is a single instance and will not exist after execution"
This is a single instance and will not exist after execution

docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
54198bf79793        busybox:1.24            "sleep 1000"             14 minutes ago      Up 14 minutes                                                                 unruffled_pike
700684301a2c        busybox:1.24            "-i -t"                  7 hours ago         Created                                                                       friendly_mclean
```

A container name can be used to explicitly tell docker which container we want to run. This will prevent container spawning
when using `docker run`

```
docker run --name base_cont busybox:1.24

docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
61d1b4cbdd0f        busybox:1.24            "sh"                     7 seconds ago       Exited (0) 6 seconds ago                                                      base_cont
54198bf79793        busybox:1.24            "sleep 1000"             20 minutes ago      Exited (0) 3 minutes ago                                                      unruffled_pike
700684301a2c        busybox:1.24            "-i -t"                  7 hours ago         Created                                                                       friendly_mclean
```

`inspect` allows us to view low level image/container information.

```
docker inspect base_cont | grep 'Image\|LogPath'
        "Image": "sha256:47bcc53f74dc94b1920f0b34f6036096526296767650f223433fe65c35f149eb",
        "LogPath": "/var/lib/docker/containers/61d1b4cbdd0f1c30d4685dc3a36af89ce9b6255476c17d9e7097db676fa3865c/61d1b4cbdd0f1c30d4685dc3a36af89ce9b6255476c17d9e7097db676fa3865c-json.log",
            "Image": "busybox:1.24",
```

### Docker Port Mapping and Docker logstash

Docker can use other ports, we don't need to specify defaults. We use `tomcat`, a web server capable of running java servlets.
We specify port mapping with -p:

-p local_port:container_port

 ```
 docker run -it --name base_tomcat -p 8484:8080 tomcat:8.0
Unable to find image 'tomcat:8.0' locally
8.0: Pulling from library/tomcat
f189db1b88b3: Pull complete
3d06cf2f1b5e: Pull complete
edd0da9e3091: Pull complete
eb7768aae14e: Pull complete
e2780f585e0f: Pull complete
e5ed720afeba: Pull complete
d9e134700cfc: Pull complete
e4804b33d02a: Pull complete
b9df0c24315e: Pull complete
49fdae8eaa20: Pull complete
1aea3d9a32e6: Pull complete

10-Dec-2018 03:51:33.904 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-apr-8080"]
10-Dec-2018 03:51:33.929 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["ajp-apr-8009"]
10-Dec-2018 03:51:33.933 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in 1250 ms
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/tomcat.png)

### View docker logs:

```
docker logs tomcat_base_8
10-Dec-2018 04:08:57.787 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server version:        Apache Tomcat/8.0.53
10-Dec-2018 04:08:57.788 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server built:          Jun 29 2018 14:42:45 UTC
------------------------------------------------------------------------------------------------------------------------------------------
10-Dec-2018 04:08:59.313 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-apr-8080"]
10-Dec-2018 04:08:59.347 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["ajp-apr-8009"]
10-Dec-2018 04:08:59.361 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in 1375 ms
```
