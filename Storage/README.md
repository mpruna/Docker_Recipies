### About storage drivers

It’s important to know how Docker builds and stores images, and how these images are used by containers.

### Images and layers

A Docker image is built up from a series of layers. Each layer represents an instruction in the image’s Dockerfile. Each layer except the very last one is read-only. Consider the following Dockerfile:

```
FROM ubuntu:15.04
COPY . /app
RUN make /app
CMD python /app/app.py
```

This Dockerfile contains four commands, each of which creates a layer. The FROM statement starts out by creating a layer from the ubuntu:15.04 image. The COPY command adds some files from your Docker client’s current directory. The RUN command builds your application using the make command. Finally, the last layer specifies what command to run within the container.

Each layer is only a set of differences from the layer before it. The layers are stacked on top of each other. When you create a new container, you add a new writable layer on top of the underlying layers. This layer is often called the “container layer”. All changes made to the running container, such as writing new files, modifying existing files, and deleting files, are written to this thin writable container layer.


### Container and layers

The major difference between a container and an image is the top writable layer. All writes to the container that add new or modify existing data are stored in this writable layer. When the container is deleted, the writable layer is also deleted. The underlying image remains unchanged.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/containers_layers.jpeg)

### Container size on disk

To view the approximate size of a running container, you can use the docker ps -s command. Two different columns relate to size.

    size: the amount of data (on disk) that is used for the writable layer of each container.

    virtual size: the amount of data used for the read-only image data used by the container plus the container’s writable layer size. Multiple containers may share some or all read-only image data. Two containers started from the same image share 100% of the read-only data, while two containers with different images which have layers in common share those common layers. Therefore, you can’t just total the virtual sizes. This over-estimates the total disk usage by a potentially non-trivial amount.


docker ps -s
```
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                                              NAMES               SIZE
5e8b2c5fe1e3        elasticsearch:latest   "/docker-entrypoint.…"   5 weeks ago         Up About an hour    0.0.0.0:32769->9200/tcp, 0.0.0.0:32768->9300/tcp   brave_bartik        539MB (virtual 1.02GB)
a8b35e1d2b96        portainer/portainer    "/portainer"             5 months ago        Up About an hour    0.0.0.0:9000->9000/tcp                             portainer           0B (virtual 57MB)
```

The total disk space used by all of the running containers on disk is some combination of each container’s size and the virtual size values.

### Sharing promotes smaller images

When you use docker pull to pull down an image from a repository, or when you create a container from an image that does not yet exist locally, each layer is pulled down separately, and stored in Docker’s local storage area, which is usually /var/lib/docker/ on Linux hosts. You can see these layers being pulled in this example

docker pull ubuntu
```
Using default tag: latest
latest: Pulling from library/ubuntu
32802c0cfa4d: Pull complete
da1315cffa03: Pull complete
fa83472a3562: Pull complete
f85999a86bef: Pull complete
Digest: sha256:6d0e0c26489e33f5a6f0020edface2727db9489744ecc9b4f50c7fa671f23c49
Status: Downloaded newer image for ubuntu:latest
```

Each of these layers is stored in its own directory inside the Docker host’s local storage area. To examine the layers on the filesystem, list the contents of /var/lib/docker/<storage-driver>/layers/

ls /var/lib/docker/overlay2/l/
```
2MPMMUWXXSD7V3SJ4JJMY736BR  BALAFTOJZYMTLH6R7GFMTK36ZH  H3OZPUMDLPINBZVSHMXYYGDJL6  LPOURUJZGCEGDY5IKQM7QFCEYI  PIEIUWA424UZEZTTG3WPVKFJJP  U44ZP3RKLGRSPUNZNT5HGGF22W  WMBYIHGWGKOE2KR7NMMQNXBECA
2XLVUXCC7IY7QIXZYTQBDVNZOI  BHGM3A6HDEMIHP2MIBOPM7RTO4  H4JZBZ5UNRBDBCFLPSZZHDXID3  LTNBDK445U5TEMNMIXCHY3LUBV  PJVMVZMXMQCWYIB2UWMXU4NL5V  U4KNTPS43RZANB3WYVESMX5KZI  XIL57NGYYE5725VJMSB2KIWIXC
3X7MHNODTJL2AHIFFTX3UW2W7V  CKJMEUBSIDK3SNY36LCO5VIPLR  HF3HNA4ARQKBTC2KHU3S2QJ6KX  N6Y5K5WCLGTCA2YH5LTQPAG7H3  PO2YMX5IPQIYDGW75BTSVZRU27  UEXQQVSAEEDBE4O6K53YXGA4DA  ZOOVZ22GYCKFARCAV7YJHLI3MU
4EHG4FIOXOXMNJB5GDHWPLQB6W  DIIO53RRZHSN5KNEUNWNR7ALUL  HHSWQTRM524YPJFVWMGPBHALUZ  OM6622NDJTIKZRETIJOMR7CVQN  PVG35Y6Y6LSRDBVGJGADKW2D2J  UM2NESRFZTBNBT4Z6VSNSG64PO  ZSK3SZVXWTH2IETIWX6XSV6W3O
6AQ77XUXQRT65Q3YY4EQPHTKGB  EGNWSGI3MS57UXC4UDEFXAZPC7  KYBKH2Y55WYNO5REEGTTBRXGYP  P3EO2IBS7IF5ETRWKHTNSEX5DQ  Q3VROH4PBKJLAKLRI2CM2OJ5JU  W3JFP5MQYUBP47WNZJLMTVCVXY
7MHAFG4HZVLWALGNM5KNMQBM34  EHMINIB257B5AZAWXKHKKRNS2I  KZNPVJG2PDVFFO2J2KP362K6AT  P6NVD7PYGQX3ESVLFUOEDYP45I  QBMC25FVDCENQ3TM2WOM4V2GJS  W6IAJEJVUPXGQQ5O3IAFCKDS4Z
A2GU5IYV5VXB44CXPAUNH6FR32  FZX2BH3LUAE6U3BP2J42JPSN4U  KZZE2TVZJOZ4Z4FK6LCD26UIX4  PEJAODJNPFVD3JLVWWT45V7IVE  S2G26EVB5R2NRW7L6OUPJM7DZK  W7NXKYQGTNB3P6WWMN5RDSADDR
ANXN4C4FKHV6TA6UDMV7DQOV2I  GZXXRUK2GCRATIEVHE665K66BP  LBA6DNMV32XFAEHD6GFPZM3VLK  PEWHHULCFZQTRZIAAIW4O2BFSJ  TAQMJLUSJ3AIQR4YFADVC2LEVD  WLKMWQYNKDE3RL7DYUAFNLFJSM
```

Current version uses overlay2 driver

docker info

```
Containers: 2
 Running: 2
 Paused: 0
 Stopped: 0
Images: 25
Server Version: 18.09.0
Storage Driver: overlay2
 Backing Filesystem: extfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
```

 ### `OverlayFS` storage driver

 OverlayFS is a modern union filesystem that is similar to AUFS, but faster and with a simpler implementation. Docker provides two storage drivers for OverlayFS: the original overlay, and the newer and more stable overlay2.

```
 ls -l /var/lib/docker/overlay2 | wc -l
 54
```
```
ls -l /var/lib/docker/overlay2 | tail -10
drwx------ 4 root root 4096 Dec 10 20:34 c891c58be38ecb7660b718438b54c8aa7d3ea68f43f31670bb81968088b15a34
drwx------ 3 root root 4096 Oct  5 09:34 d0bb827ef8a0a6825ca3240ee7f56baeb53db1dab262aad2dbed8f20fa6d2269
drwx------ 3 root root 4096 Dec 10 06:54 d47acc9ee851ebd0b0ca2cd09c3e16a05ecab8f28bdfc70c677358735efcfe58
drwx------ 4 root root 4096 Oct  5 09:35 d66169f86ba9c0216288b09d72701d93a2a7885c3488feb92021613b9fd92340
drwx------ 3 root root 4096 Dec 22 14:40 d94f158e97e4d07e7ed1e967b9a7986d98cc522dd002730d726531ba66d9ae9c
drwx------ 4 root root 4096 Dec 13 04:41 dda09f7be92c08ba7f2a8183aa17648fb9796d0a0c5ac82147657287218accd8
drwx------ 4 root root 4096 Oct  5 09:34 e9829d0537a86751e1497ea0a6e0d89d6eafb116b9656033aab1b16eef025658
drwx------ 4 root root 4096 Dec 10 20:32 f364b0c3e7b67a1ddc7fb6304c7d1ccaafca466cef87ef52bbeae022696f4c33
drwx------ 4 root root 4096 Dec 10 20:34 ff31d8e16092d07f6b1c1a75a76a11a8fece86add3ffa00f8fa40a438fdafbf8
drwx------ 2 root root 4096 Dec 22 14:40 l
```

### How the overlay2 driver works

OverlayFS layers two directories on a single Linux host and presents them as a single directory. These directories are called layers and the unification process is referred to as a union mount. OverlayFS refers to the lower directory as lowerdir and the upper directory a upperdir. The unified view is exposed through its own directory called merged.

The new l (lowercase L) directory contains shortened layer identifiers as symbolic links. These identifiers are used to avoid hitting the page size limitation on arguments to the mount command

ls -l /var/lib/docker/overlay2/l
```
total 208
lrwxrwxrwx 1 root root 72 Dec 13 05:25 2MPMMUWXXSD7V3SJ4JJMY736BR -> ../75fe6af999aaac47b15f4328305bca9bfbf0342eacabd1dec5d8e2a92f02657f/diff
lrwxrwxrwx 1 root root 72 Dec 13 04:41 2XLVUXCC7IY7QIXZYTQBDVNZOI -> ../a9ba5969f939a9136276f45924924decf05169dda35bf9a8fc39e3c44dbcc316/diff
lrwxrwxrwx 1 root root 72 Oct  5 09:35 3X7MHNODTJL2AHIFFTX3UW2W7V ->
------------------------------------------------------------------------------------------------------------
-lrwxrwxrwx 1 root root 72 Dec 13 05:25 XIL57NGYYE5725VJMSB2KIWIXC -> ../b3327ac57a9a7712f2829026f9db1bd4fbfe3cf01824564f6ebd0f5fd3eeb6bc/diff
lrwxrwxrwx 1 root root 72 Dec 10 20:34 ZOOVZ22GYCKFARCAV7YJHLI3MU -> ../ff31d8e16092d07f6b1c1a75a76a11a8fece86add3ffa00f8fa40a438fdafbf8/diff
lrwxrwxrwx 1 root root 72 Nov 16 19:22 ZSK3SZVXWTH2IETIWX6XSV6W3O -> ../16f52552c10ee4c18c8fb53ab7187ed206358e7217a2d8edf2a16721e5b39ad7/diff
```

The lowest layer contains a file called link, which contains the name of the shortened identifier, and a directory called diff which contains the layer’s contents.

```
pwd
/var/lib/docker/overlay2
ls 461217dbf30efe2cb149e7d786538be4b56cce497dbc7ddd696a75d980f489ae
diff  link  lower  work
```

cat lower
```
l/WLKMWQYNKDE3RL7DYUAFNLFJSM:l/TAQMJLUSJ3AIQR4YFADVC2LEVD:l/PEWHHULCFZQTRZIAAIW4O2BFSJ
 ```

cat link
```
P3EO2IBS7IF5ETRWKHTNSEX5DQ
```

ls diff/
```
run
```

The second-lowest layer, and each higher layer, contain a file called lower, which denotes its parent, and a directory called diff which contains its contents. It also contains a merged directory, which contains the unified contents of its parent layer and itself, and a work directory which is used internally by OverlayFS.

### How the overlay2 driver works

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/overlay.jpg)

OverlayFS layers two directories on a single Linux host and presents them as a single directory. These directories are called layers and the unification process is referred to as a union mount. OverlayFS refers to the lower directory as lowerdir and the upper directory a upperdir. The unified view is exposed through its own directory called merged.

While the overlay driver only works with a single lower OverlayFS layer and hence requires hard links for implementation of multi-layered images, the overlay2 driver natively supports up to 128 lower OverlayFS layers. This capability provides better performance for layer-related Docker commands such as docker build and docker commit, and consumes fewer inodes on the backing filesystem

### Image and container layers on-disk

The following docker pull command shows a Docker host downloading a Docker image comprising five layers.

docker pull ubuntu
```
Using default tag: latest
latest: Pulling from library/ubuntu
32802c0cfa4d: Pull complete
da1315cffa03: Pull complete
fa83472a3562: Pull complete
f85999a86bef: Pull complete
Digest: sha256:6d0e0c26489e33f5a6f0020edface2727db9489744ecc9b4f50c7fa671f23c49
Status: Downloaded newer image for ubuntu:latest
```

Each image layer has its own directory within /var/lib/docker/overlay/, which contains its contents, as shown below. The image layer IDs do not correspond to the directory IDs.

### The container layer

Containers also exist on-disk in the Docker host’s filesystem under /var/lib/docker/overlay/. If you list a running container’s subdirectory using the ls -l command, three directories and one file exist:

$ ls -l /var/lib/docker/overlay/<directory-of-running-container>
```
total 16
-rw-r--r-- 1 root root   64 Jun 20 16:39 lower-id
drwxr-xr-x 1 root root 4096 Jun 20 16:39 merged
drwxr-xr-x 4 root root 4096 Jun 20 16:39 upper
drwx------ 3 root root 4096 Jun 20 16:39 work
```
