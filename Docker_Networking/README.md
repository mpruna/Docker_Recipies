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

Docker containers use `network bridge 0` to connect to outside world. When docker is initialized it creates a bridge network:

```
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
b320e7db303f        bridge              bridge              local
e96e024ae197        dockerapp_default   bridge              local
2eb144e0227b        host                host                local
c34e8514466e        none                null                local
```
### Check out the bridge network config:

```
docker inspect bridge
[
    {
        "Name": "bridge",
        "Id": "b320e7db303fe0626805ce97f5da233c796c247fa0b975d2e712b609f3657a23",
        "Created": "2018-12-15T05:20:22.236413676+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
```

We can see that `172.17.0.0-172.16.255.255` ip range is allocated for bridge network.
By default when a container is created the bridge network type is used.
Let's check that by creating a busybox container:

```
docker run -d --name container_1 busybox sleep 1000
17c595106ddc080461011fc0748f517c781be63e48879aac00ccfc99c56532e6
```

Check ip addr allocated:

```
docker exec -it container_1 ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:04  
          inet addr:172.17.0.4  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:726 (726.0 B)  TX bytes:0 (0.0 B)
```

Ip address in container_1 is within the bridge network range.
Let's create another container and see if containers can communicate with each other and with the outside World

```
docker run -d --name container_2 busybox sleep 1000
e50cb7257f3ef1de965d1db59fc85e733260eeb7e185ac14d94c63f9fd64a159
```

```
docker exec -it container_2 ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:42:AC:11:00:05  
          inet addr:172.17.0.5  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:656 (656.0 B)  TX bytes:0 (0.0 B)
```

### Check inter container networking:

```
docker exec container_1 ping 172.17.0.5
PING 172.17.0.5 (172.17.0.5): 56 data bytes
64 bytes from 172.17.0.5: seq=0 ttl=64 time=0.145 ms
64 bytes from 172.17.0.5: seq=1 ttl=64 time=0.214 ms
```

```
docker exec container_2 ping 172.17.0.4
PING 172.17.0.4 (172.17.0.4): 56 data bytes
64 bytes from 172.17.0.4: seq=0 ttl=64 time=0.139 ms
64 bytes from 172.17.0.4: seq=1 ttl=64 time=0.235 ms
```


### Check outside world connectivity:

```
docker exec container_1 ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=120 time=39.107 ms
64 bytes from 8.8.8.8: seq=1 ttl=120 time=38.575 ms
```

```
docker exec container_2 ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=120 time=38.802 ms
64 bytes from 8.8.8.8: seq=1 ttl=120 time=38.241 ms
```

There can be multiple bridge networks, and containers running on a bridge network can communicate with each other.
But containers defined on different bridge networks can't communicate by default.
We will create a different bridge network and build a container on that network.

```
docker network create --driver bridge bridge_two
b9908d6d8a0228386c0e97e521ce71b777111f04c1f7905ada738f868d1fd8f2
```

List networks:

```
docker network list
NETWORK ID          NAME                DRIVER              SCOPE
b320e7db303f        bridge              bridge              local
b9908d6d8a02        bridge_two          bridge              local
e96e024ae197        dockerapp_default   bridge              local
2eb144e0227b        host                host                local
c34e8514466e        none                null                local
```

Create new container on `bridge_two`:

```
docker run -d --name container_3 --net bridge_two busybox sleep 1000
bf0bb63a7cdafcec164ca1f92324b55bf8b43dee29bde195f986b771c08bb6c6
```

Check ip config:

```
docker exec container_3 ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 02:42:AC:13:00:02  
          inet addr:172.19.0.2  Bcast:172.19.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:10 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:836 (836.0 B)  TX bytes:0 (0.0 B)
```

`172.19.0.0-172.19.255.255` ip range

Ping not working between containers:

```
docker exec -it container_3 ping 172.17.0.4
PING 172.17.0.4 (172.17.0.4): 56 data bytes
^C
--- 172.17.0.4 ping statistics ---
9 packets transmitted, 0 packets received, 100% packet loss
```

This behavior can be overwritten by bridging container_3 to `bridge` network using `connect` option

```
docker network connect bridge container_3
```

Check interfaces:

```
docker exec -it container_3 ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:13:00:02  
          inet addr:172.19.0.2  Bcast:172.19.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:31 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2986 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1914 (1.8 KiB)  TX bytes:291844 (285.0 KiB)

eth1      Link encap:Ethernet  HWaddr 02:42:AC:11:00:05  
          inet addr:172.17.0.5  Bcast:172.17.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:222 errors:0 dropped:0 overruns:0 frame:0
          TX packets:212 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:21348 (20.8 KiB)  TX bytes:20552 (20.0 KiB)
```

New interface is added on `bridge` network:

### Disconnect from `bridge`:

```
docker network disconnect bridge container_3


docker exec container_3 ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:13:00:02  
          inet addr:172.19.0.2  Bcast:172.19.255.255  Mask:255.255.0.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:32 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3035 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1956 (1.9 KiB)  TX bytes:296590 (289.6 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:766 errors:0 dropped:0 overruns:0 frame:0
          TX packets:766 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:64344 (62.8 KiB)  TX bytes:64344 (62.8 KiB)
```
### Bridge Network summary

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/bridge_network_sumup.png)
