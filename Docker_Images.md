### Docker images

Docker is comprised of read only layers stacked on top of each other. This was a base for the container in use is formed.
An image can reference a parent image, and the image at the bottom is the base image.
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/image_layers.png)

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
This layer is often called the "writable container layer". All changes made to the running container, such as writing new
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

Docker commit

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
