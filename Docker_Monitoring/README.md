### Docker Monitoring

Monitoring docker containers is vital for running applications that must have close to 99% availability.
There are several options here.

### 1 Docker stats

You can use the docker stats command to live stream a container’s runtime metrics. The command supports CPU, memory usage, memory limit, and network IO metrics.
The following is a sample output from the docker stats command

Ref: 
    https://docs.docker.com/config/containers/runmetrics/

As an examples let's use a **docker elk stack** deployment and monitor it

```buildoutcfg
$ docker-compose up
Starting dockerelk_elasticsearch_1 ... done
Starting dockerelk_kibana_1        ... done
Starting dockerelk_logstash_1      ... done
```

### Check with docker ps

```buildoutcfg
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                                            NAMES
54e580bc8efb        dockerelk_kibana          "/usr/local/bin/kiba…"   23 minutes ago      Up About a minute   0.0.0.0:5601->5601/tcp                           dockerelk_kibana_1
8f1116e7f52c        dockerelk_logstash        "/usr/local/bin/dock…"   23 minutes ago      Up About a minute   0.0.0.0:5044->5044/tcp, 9600/tcp                 dockerelk_logstash_1
aed251afb2cf        dockerelk_elasticsearch   "/usr/local/bin/dock…"   23 minutes ago      Up About a minute   0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp   dockerelk_elasticsearch_1
```

### docker stats

```buildoutcfg
CONTAINER ID        NAME                        CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
54e580bc8efb        dockerelk_kibana_1          2.67%               266.2MiB / 3.858GiB   6.74%               166kB / 268kB       0B / 18.8MB         10
8f1116e7f52c        dockerelk_logstash_1        3.58%               591.4MiB / 3.858GiB   14.97%              2.62kB / 2.07kB     5.32MB / 2.49MB     39
aed251afb2cf        dockerelk_elasticsearch_1   5.50%               872.5MiB / 3.858GiB   22.09%              271kB / 167kB       0B / 266kB          59
```