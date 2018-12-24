### Docker images

Docker is comprised of read only layers stacked on top of each other. A base image is the foundation for  every container.
An image can reference a parent image, and the image at the bottom is the base image.
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/image_layers.png)

A Docker image is made up of filesystems layered over each other. At the
base is a boot filesystem, bootfs , which resembles the typical Linux/Unix boot
filesystem. A Docker user will probably never interact with the boot filesystem.
Indeed, when a container has booted, it is moved into memory, and the boot
filesystem is unmounted to free up the RAM used by the initrd disk image.
So far this looks pretty much like a typical Linux virtualization stack. Indeed,
Docker next layers a root filesystem, rootfs , on top of the boot filesystem. This
rootfs can be one or more operating systems (e.g., a Debian or Ubuntu filesys-
tem).

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/bootrootfs.png)


This is visible with `--history` cmd


```
docker history busybox:1.24
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
47bcc53f74dc        2 years ago         /bin/sh -c #(nop) CMD ["sh"]                    0B                  
<missing>           2 years ago         /bin/sh -c #(nop) ADD file:47ca6e777c36a4cff…   1.11MB  
```
  - the base layers adds a file `47ca6e777c36a4cff… `
  - second layer or container is the shell `CMD ["sh"]`

When we create a new container, you add a new, thin and writable layer on top of the underlying stack.
This layer is often called the `writable container layer`. All changes made to the running container, such as writing new
files, modifying existing files, and deleting files are written to this thin writable container layer.
Multiple containers can share the underlying image but have different data state.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/writable_layer.png)


### Building docker images:

  - make changes to a Docker containers
  - write a docker file

Make changes to a container:
1. Spin up a container from a base image.
2. Install Git package in the container.
3. Commit changes made in the container.

Pull Debian Jessie:


```
docker run -it --name jessie debian:jessie
Unable to find image 'debian:jessie' locally
jessie: Pulling from library/debian
4b105072aa89: Pull complete
Digest: sha256:14e15b63bf3c26dac4f6e782dbb4c9877fb88d7d5978d202cb64065b1e01a88b
Status: Downloaded newer image for debian:jessie
```

Update and upgrade Debian:

```apt-get update && apt-get upgrade
```

Install git and automatically confirm with yes to any install '-y':

```
apt-get install git -y
```

### Docker commit

Docker commit command would save the changes we made to the Docker container’s file system to a new image.

```
docker commit jessie mpruna/debian:1.00
sha256:d9bbe106c013917cb0211679212a183cc3cabf207b499915998e11d1c054775a

docker images
REPOSITORY              TAG                 IMAGE ID            CREATED              SIZE
mpruna/debian           1.00                d9bbe106c013        About a minute ago   252MB
```

Create a new container based on the new image:

```
docker run --name debian_v1 -d mpruna/debian:1.00 "echo Horray"
4abcb84e3d6c11127d21f14ba78db577763762032f9c1a2566ce46445d5325e8

docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                                              NAMES
4abcb84e3d6c        mpruna/debian:1.00      "echo Horray"            23 seconds ago      Created                                                                       debian_v1
```

Remove docker images with `rmi` switch

```
docker images
busybox                 1.24                47bcc53f74dc        2 years ago          1.11MB

docker rmi 47bcc53f74dc
Untagged: busybox:1.24
Untagged: busybox@sha256:8ea3273d79b47a8b6d018be398c17590a4b5ec604515f416c5b797db9dde3ad8
Deleted: sha256:47bcc53f74dc94b1920f0b34f6036096526296767650f223433fe65c35f149eb
Deleted: sha256:f6075681a244e9df4ab126bce921292673c9f37f71b20f6be1dd3bb99b4fdd72
Deleted: sha256:1834950e52ce4d5a88a1bbd131c537f4d0e56d10ff0dd69e66be3b7dfa9df7e6
```

### Build images using docker files

Dockerfile and Instructions:
  - A Dockerfile is a text document that contains all the
instructions users provide to assemble an image.
  - Each instruction will create a new image layer to the image.
  - Instructions specify what to do when building the image.

Docker Build Context
  - Docker build command takes the path to the build context as an argument.
  - When build starts, docker client would pack all the files in the build context into a tarball then transfer the tarball file to the daemon.
  - By default, docker would search for the Dockerfile in the build context path.

Creating a Dockerfile with instructions. Dockerfile must not have an extension. Although the commands are case-insensitive,
we use capital letter to specify the command and small letter as arguments. `FROM` tells which docker image to fetch and `RUN`
are Linux commands that will be executed.

```
nano Dockerfile

FROM debian:latest
RUN apt-get update && apt-get upgrade -y
RUN apt-get install git -y
RUN apt-get install vim -y
RUN apt-get install nano -y
```

Build docker image from local file. `-t` tags the image and `.` sets the context to local/current directory.
As we mentioned before, now the Docker client is transferring the all the files inside the build
context which is my current folder from the local machine to the Docker daemon. Then instructions are executed

```
docker build -t mpruna/debian .
Sending build context to Docker daemon  10.02MB
Step 1/5 : FROM debian:latest
 ---> be2868bebaba
Step 2/5 : RUN apt-get update && apt-get upgrade -y
 ---> Running in deea5a1e22d2
Removing intermediate container deea5a1e22d2
---> 62796d978db6
Step 3/5 : RUN apt-get install git -y
---> Running in 339b252eb98b
Removing intermediate container 339b252eb98b
---> 96ca7cd22921
Step 4/5 : RUN apt-get install vim -y
---> Running in 1810fbc975d7
Removing intermediate container 1810fbc975d7
---> 0b8c03b0f865
Step 5/5 : RUN apt-get install nano -y
---> Running in ce52a31b05e2
Removing intermediate container ce52a31b05e2
 ---> 612bb4a71047
Successfully built 612bb4a71047
Successfully tagged mpruna/debian:latest
```

### Docker COPY and ADD

The `COPY` instruction copies new files or directories from build context and adds them to the file system of the container.

```
echo "Welcome Home" >> text.txt
```

Dockerfile includes COPY `cmd`:

```
FROM debian:latest
RUN apt-get update && apt-get install -y \
	git\
	nano
COPY text.txt /home/test.txt
```

Build a container:

```
docker build -t mpruna/debian .
Sending build context to Docker daemon  10.03MB
Step 1/3 : FROM debian:latest
 ---> be2868bebaba
Step 2/3 : RUN apt-get update && apt-get install -y 	git	nano
 ---> Running in 6af1280f6285

 Running hooks in /etc/ca-certificates/update.d...
 done.
 Removing intermediate container 6af1280f6285
  ---> 8f6b8efc02f1
 Step 3/3 : COPY text.txt /home/test.txt
  ---> e1b82b13368a
 Successfully built e1b82b13368a
 Successfully tagged mpruna/debian:latest
```

Check `test.txt` is in `/home` directory

```
docker run -it --name debian_latest mpruna/debian
root@9716fad24def:/# cd /home/
root@9716fad24def:/home# ls -ltr
total 4
-rw-r--r-- 1 root root 13 Dec 10 16:39 test.txt
root@9716fad24def:/home#
```

`ADD` allows you to download a file from internet and copy to the container. `ADD` also has the ability to automatically
unpack compressed files. If the src argument is a local file in a recognized compression format then it is unpacked at the specified dest
path in the container's filesystem.

### Push an image to Docker Hub

  1. First, we must create a [Docker Hub](https://hub.docker.com/) account.
  2. Tag one of the images we want to push. We should avoid naming an image with latest. This is just a naming convention but it's not enforced. Images tagged latest will not be updated automatically when a new version is pushed to the repository.

     ```
     docker tag e1b82b13368a praslea/debian:1.01

     REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
     debian                  jessie              39db55273026        3 weeks ago         127MB
     praslea/debian          1.01                39db55273026        3 weeks ago         127MB
     ```
  3. Log in to Docker hub:
    ```
    docker login --username=praslea
    Login Succeeded
    ```
  4. Push the image:
    ```
    docker push praslea/debian:1.01
    The push refers to repository [docker.io/praslea/debian]
    2eccc496e148: Mounted from library/debian
    1.01: digest: sha256:3eccaca582cda1523b94e8451100fccfc9a0b2b1d09936f48250d51318e3948f size: 529
    ```

### Image present on Docker Hub:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/docker_hub_push.png)

### Docker integration:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/integration.png)
=======
### Docker chain RUN instructions:

 - Each `RUN` command will execute the command on the top writable layer of the container, then commit the container as a new image.
 - The new image is used for the next step in the Dockerfile. So each `RUN` instruction will create a new image layer.
 - It is recommended to chain the RUN instructions in the Dockerfile to reduce the number of image layers it creates.

It is recommended to chain the RUN instructions in Dockerfile to reduce the number of image layers it creates.
Instead of having 3 instructions, we will do `apt-get update and apt-get install git and vim` to aggregate those three instructions into one.
By editing the Dockerfile we have only two build steps instead of four, which means it is only adding one more layer on top of the base image instead of three.

```
FROM debian:latest
RUN apt-get update && apt-get install -y \
    git \
    nano
```

Docker run the new Dockerfile

```
docker build -t mpruna/debian .
Sending build context to Docker daemon  3.014MB
Step 1/2 : FROM debian:latest
latest: Pulling from library/debian
54f7e8ac135a: Pull complete
Digest: sha256:df6ebd5e9c87d0d7381360209f3a05c62981b5c2a3ec94228da4082ba07c4f05
Status: Downloaded newer image for debian:latest
 ---> 4879790bd60d
Step 2/2 : RUN apt-get update && apt-get install -y     git     nano
 ---> Running in ab785a270c7f
 Removing intermediate container ab785a270c7f
 ---> 744f8cfd728b
Successfully built 744f8cfd728b
Successfully tagged mpruna/debian:latest
 ```

 Another good practice is to add packages/library alphanumerically so we avoid duplication.

### CMD Instructions:

 - CMD instruction specifies what command you want to run when the container starts up.
 - If we don't specify CMD instruction in the Dockerfile, Docker will use the default command defined in the base image.
 - The CMD instruction doesn’t run when building the image, it only runs when the container starts up.
 - You can specify the command in either exec form which is preferred or in shell form.
 - By default when a container starts it also spawn a `bash shell`

This can be exemplified appending a different cmd

```
FROM debian:latest
RUN apt-get update && apt-get install -y \
    git \
    nano
CMD ["echo","hello world!"]
```


```
docker build -t mpruna/debian .
Sending build context to Docker daemon  3.015MB
Step 1/3 : FROM debian:latest
 ---> 4879790bd60d
Step 2/3 : RUN apt-get update && apt-get install -y     git     nano
 ---> Using cache
 ---> 744f8cfd728b
Step 3/3 : CMD ["echo","hello world!"]
 ---> Running in fa22799bb2bc
Removing intermediate container fa22799bb2bc
 ---> 0d7454cad615
Successfully built 0d7454cad615
Successfully tagged mpruna/debian:latest
```

Run container:

```
docker run 0d7454cad615
hello world!
```

Also default docker container run instruction can be overwritten if we choose a different command.

```
docker run 0d7454cad615 echo "hello docker!"
hello docker!
```

### Docker Cache:

 - Each time Docker executes an instruction it builds a new image layer.
 - The next time, if the instruction doesn't change, Docker will simply reuse the existing layer, as seen in the previously when we update the Dockerfile.

If the same instruction is seen in a Dockerfile docker-engine interprets the previous command as being
executed and it will not execute it one more time. This can cause problems as for subsequent packet installs might require an update.
Solution would be do chain the commands

### Aggresive cacheing
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/aggresive_cache.png)

### Chain instruction
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/chain_solution.png)

Also `--no-cache=True` command can be used to invalidate this behavior

```
docker build -t mpruna/debian . --no-cache=True
Sending build context to Docker daemon  3.263MB
Step 1/3 : FROM debian:latest
 ---> 4879790bd60d
Step 2/3 : RUN apt-get update && apt-get install -y     git     nano
 ---> Running in 3f817a9dd129

Running hooks in /etc/ca-certificates/update.d...
done.
Removing intermediate container 3f817a9dd129
 ---> 67c379c9de7b
Step 3/3 : CMD ["echo","hello world!"]
 ---> Running in 81ba19ec1e42
Removing intermediate container 81ba19ec1e42
 ---> c68f737959a7
Successfully built c68f737959a7
Successfully tagged mpruna/debian:latest
>>>>>>> 35e8c29df58c0d8795e87d4cd724a4c9a7f5aa3b
```

### Commands sum-up

Commands | Description
-|-
docker history | Show the history of an image. It's useful if we want to know the image dependencies.
docker commit | Create a new image from a container's changes
docker images | Lists images
docker build | Build an image from a Dockerfile
COPY | copies new files or directories from build context and adds them to the file system of the container
ADD | ADD allows you to download a file from internet and copy to the container. ADD also has the ability to automatically unpack compressed files
docker tag | Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
docker login --username | Login to DockerHub
docker push | Push docker image to DockerHub

### Commands common arguments
Commands | Arguments
-|-
docker build `-t` | Tags an image
docker build `.` | Uses the current directory for the build path
docker run `other cmd` | `cmd` specified as argument overwrites default docker run command
docker build `--no-cache=True` | ignores docker default image caching