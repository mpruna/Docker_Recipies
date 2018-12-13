### Docker Networking

Docker uses the networking capabilities of the host machine operating system to provide networking support for the containers running on the host machine.
Once the Docker daemon is installed on the host machine, A bridge network interface "Docker 0" is provisioned on the host which will be used to bridge the traffic from the outside network to the internal containers hosted on the host machine.

Each container connects to the bridge network through its container network interface.
Containers can connect to each other and connect to the outside world through this bridge network interface.

### Docker default network Model

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/default_network_model.png)

### Docker network types:
  - Closed Network / None Network
  - Bridge Network
  - Host Network
  - Overlay Network

### List all docker networks:

```
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
595dacc6809f        bridge              bridge              local
e96e024ae197        dockerapp_default   bridge              local
2eb144e0227b        host                host                local
c34e8514466e        none                null                local
```

### None Network/Closed CONTAINER

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/none_network.png)

Container is completely isolated from the outside World. This type of network is suitable for cases where internet connectivity is not required.
Also this provides the maximum level of protection.
Setup none network by using docker with `--net none` option.
Start busybox with none network and sleep 1000, this way we are guaranteed the container will not close.

```
docker run -d --net none busybox sleep 10000
e6730854fb53c3df4b8d1c5b38869ada2911eaf1b0447145bc39fca41a464369
```
Log on to busybox:
```
docker exec -it e6730854fb53c3df4b8d1c5b38869ada2911eaf1b0447145bc39fca41a464369 /bin/ash
```
Pinging outside world is not possible from machine:

```
ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
ping: sendto: Network is unreachable
/ # route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
/ # ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
/ #
```

### Docker bridged Network(Docker Default)

Docker containers use `network bridge 0` to connect to outside world:
