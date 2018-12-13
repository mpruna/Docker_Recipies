### Docker recipes

### What is Docker:

In this `Github Repo` we will cover some of the most important aspects of using and understanding docker.

Docker is a container based operating-system-level virtualization.
Within Docker applications are built on containers based on specific images.
Each application and its dependencies use a partitioned segment of the operating system’s resources. The container runtime (Docker, most often) sets up and tears down the containers by drawing on the low-level container services provided by the host operating system.

Docker is a tool designed to make it easier to create, deploy, and run applications by using containers. Containers allow a developer to package up an application with all of the parts it needs, such as libraries and other dependencies, and ship it all out as one package.

### Who is Docker for?
Docker is a tool that is designed to benefit both developers and system administrators, making it a part of many DevOps (developers + operations) toolchains.

### Docker Hub:

Docker images are typically hosted on [Docker_Hub](https://hub.docker.com/)
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/integration.png)


### Docker version:

```
docker version
Client:
 Version:           18.09.0
 API version:       1.39
 Go version:        go1.10.4
 Git commit:        4d60db4
 Built:             Wed Nov  7 00:48:46 2018
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.0
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.4
  Git commit:       4d60db4
  Built:            Wed Nov  7 00:16:44 2018
  OS/Arch:          linux/amd64
  Experimental:     false
```

### Repository Structure:

[Getting_Started_with_Docker](https://github.com/mpruna/Docker_Recipies/tree/master/Getting_Started_with_Docker):

  - Introduction to virtualization technologies
  - Docker Client-Server architecture
  - Docker Installation
  - Docker Concepts
  - Running a container
  - Port mapping
  - Docker Logs

[Docker Images](https://github.com/mpruna/Docker_Recipies/tree/master/Docker_Images)
  - Docker Image image layers
  - Building docker images using `docker commit`
  - Build docker images based on Dockerfile
  - Push images to Docker Hub

[Containerized Web Applications](https://github.com/mpruna/Docker_Recipies/tree/master/Containerized_Web_Applications)
  - Containerize Web applications
  - Create docker links between Containers
  - Automate docker workflow with docker-composed
