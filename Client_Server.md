### Docker Client-Server architecture

Docker uses a client-server architecture. We use docker client to interact with docker daemon and create/build/operate containers/images.
Docker daemon does the heavy lifting building, running, and distributing your Docker containers. Docker daemon is often referred as Docker engine or Docker server.
In terms of clients we can either user Linux shell based on various guys.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/client_server.png)


### Docker concepts

Images:
  • Images are read only templates used to create containers.
  • Images are created with the docker build command, either
by us or by other docker users.
  • Images are composed of layers of other images.
  • Images are stored in a Docker registry.

Containers:
  • If an image is a class, then a container is an instance of a
class - a runtime object.
  • Containers are lightweight and portable encapsulations of
an environment in which to run applications.
  • Containers are created from images. Inside a container, it
has all the binaries and dependencies needed to run the
application.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/images_containers.jpg)

Registries and Repositories:
  • A registry is where we store our images.
  • You can host your own registry, or you can use Docker’s
public registry which is called `DockerHub`.
  • Inside a registry, images are stored in repositories.
  • Docker repository is a collection of different docker images
with the same name, that have different tags, each tag
usually represents a different version of the image.
