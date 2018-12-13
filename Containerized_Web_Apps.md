### Containerized Web Apps

Clone the source code from github, we will use branching and tag the source code with `-b v0.1`:

```
git clone -b v0.1 https://github.com/jleetutorial/dockerapp.git
Cloning into 'dockerapp'...
remote: Enumerating objects: 173, done.
remote: Total 173 (delta 0), reused 0 (delta 0), pack-reused 173
Receiving objects: 100% (173/173), 20.39 KiB | 3.40 MiB/s, done.
Resolving deltas: 100% (59/59), done.
Note: checking out '905df5bc05f266164107d8b91893eb07f518d4be'.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>
```

Let's check the flash application:

```
cd dockerapp
ls -ltr
total 8
-rw-r--r-- 1 root root  142 Dec 10 20:04 Dockerfile
drwxr-xr-x 2 root root 4096 Dec 10 20:04 app
cd app
```
View app folder the `app.py` script:

```
from flask import Flask  #<---First two lines import flask
app = Flask(__name__)

@app.route('/')          #<---Create a hello world response for /
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':  #<--- run app
    app.run(host='0.0.0.0')
```

View Dockerfile:

```
FROM python:3.5                    #<--- install python 3.5
RUN pip install Flask==0.11.1      #<--- install Flask 0.11.1
RUN useradd -ms /bin/bash admin    #<--- add admin user to bash
USER admin                         #<--- setup admin as the app user
WORKDIR /app                       #<--- setup working directory
COPY app /app                      #<--- copy local file app to '/app' folder in docker Containerized
CMD ["python", "app.py"]           #<--- execute the app
```

Build and tag the containers

```
docker build -t dockerapp:v0.1 .
Sending build context to Docker daemon  78.34kB
Step 1/7 : FROM python:3.5
3.5: Pulling from library/python
54f7e8ac135a: Pull complete
d6341e30912f: Pull complete

Removing intermediate container 09adb6a1b4a3
 ---> 907fcaa51dd3
Successfully built 907fcaa51dd3
Successfully tagged dockerapp:v0.1
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/docker_build.png)


Run docker container in the background mapping 5000 internal port to 5000 external.

```
docker run  --name flask_app -d -p 5000:5000 907fcaa51dd3
46c7a905f1e6afea0c8e5d8b7963d3dd348f6ba6f4786933b25bcf17eb0ef568
```
### Web Access to Python app
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/http_Flask.png)


Let run a command in a running container by using `exec`:

```
docker exec -it flask_app bash
admin@46c7a905f1e6:/app$
```

See inside container that admin user is running the python app:

```
ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
admin        1     0  0 02:57 ?        00:00:00 python app.py
admin        9     0  0 03:12 pts/0    00:00:00 bash
admin       19     9  0 03:13 pts/0    00:00:00 ps -ef
```

### Implement a key-value pair system:

We use [git stash](https://git-scm.com/book/en/v1/Git-Tools-Stashing) to track the  modified files and staged changes — and saves it on a stack of unfinished changes that you can reapply at any time. This comes in handy when we want to switch branches for a bit to work on something else.
[git checkout <branch>](https://git-scm.com/docs/git-checkout) To prepare for working on `<branch>`, switch to it by updating the index and the files in the working tree, and by pointing HEAD at the branch.

Switch to the directory where downloaded the project app:

```
pwd
/home/Github_projects/Docker_Recipies/dockerapp
```

Stash an checkout:

```
git stash && git checkout v0.2
No local changes to save
Previous HEAD position was 905df5b initial commit
HEAD is now at 81b086a simple key value lookup
```

### Check HTML layout for new app:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/index_html.png)

Input text fields in the web app referencing variables defined in the controller `app.py`:
```
<input type="text" name="key" value={{ key }}>
<input type="text" name="cache_value" value={{ cache_value }}>
```
Load & save buttons:

```
<input type="submit" name="submit" value="load">
<input type="submit" name="submit" value="save">
```

### New Flask app:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/flask_key_value.png)

Register URL for GET and POST HTTP:
```
@app.route('/', methods=['GET', 'POST'])
def mainpage():
```
If user specifies a key add it to the `key` variable
```
if 'key' in request.form:
    key = request.form['key']
```
Save key-value pair in dictionary:
```
if request.method == 'POST' and request.form['submit'] == 'save':
  cache[key] = request.form['cache_value']
```

Key-Value pair lookup:
```
cache_value = None;
if key in cache:
  cache_value = cache[key]    
```

Return key-value in HTML page:

```
return render_template('index.html', key=key, cache_value=cache_value)
```

Rebuild the image:

```
docker build -t dokerapp:v0.2 .
Sending build context to Docker daemon  80.38kB
Step 1/7 : FROM python:3.5
 ---> ffc8b495cd26
Step 2/7 : RUN pip install Flask==0.11.1
 ---> Using cache
 ---> b3b59aa548b9
Step 3/7 : RUN useradd -ms /bin/bash admin
 ---> Using cache
 ---> a89afc108e6b
Step 4/7 : USER admin
 ---> Using cache
 ---> f276229aa1ed
Step 5/7 : WORKDIR /app
 ---> Using cache
 ---> a88d4b670ed5
Step 6/7 : COPY app /app
 ---> e9a83de14b18
Step 7/7 : CMD ["python", "app.py"]
 ---> Running in c68417b83d41
Removing intermediate container c68417b83d41
 ---> 6dd19e7b493d
Successfully built 6dd19e7b493d
Successfully tagged dokerapp:v0.2
```

Startup a container also name the container `key_value.app`:

```
docker run --name key_value.app -d -p 5000:5000 6dd19e7b493d
91d29e3c41bcfe6966bf0d87b5b5dd74546e9166e3d2f89e67fb6668770f88e7  
```
![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/key_value_app.png)

So far our applications where built in one container, next we will explore how to develop an application across multiple containers and link them togather.
We will use `redis` in memory db. [Redis](https://redis.io/) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.
Redis has built-in replication and different levels of disk-persistence.
Used in time critical applications such as twitter Timeline and Facebook News Feed.

We must perform some modification in previous `app.py` and add `python-redis` `apis` and methods.
Below we see the differences:

```
  <  removed line
  >  added line
```
### app diff
```
diff app.py app_redis.py
1a2
> import redis
5c6,7
< cache = {default_key: 'one'}
---
> cache=redis.StrictRedis(host='localhost', port=6379, db=0)
> cache.set(default_key: 'one')
15c17
< 		cache[key] = request.form['cache_value']
---
> 		cache.set(key, request.form['cache_value'])
18,19c20,21
< 	if key in cache:
< 		cache_value = cache[key]
---
> 	if cache.get(key):
> 		cache_value = cache.get(key).decode('utf-8')
```

In Docker file we must specify `python-redis` library to Install:

```
FROM python:3.5
RUN pip install Flask==0.11.1 redis==2.10.5
```

### Container Links

Docker links work by establishing links between containers. In our particular case a link is established between `dockerapp` and `redis`.

![IMg](https://github.com/mpruna/Docker_Recipies/blob/master/images/container_links.png)


Install & run redis container:

```
docker run -d --name redis redis:3.2.0

Digest: sha256:4b24131101fa0117bcaa18ac37055fffd9176aa1a240392bb8ea85e0be50f2ce
Status: Downloaded newer image for redis:3.2.0
bff820edf4f1b6470fada4a09765b638d41d3150a775c109687ea8986e199689
```

Build the new app and tag it with a new version `0.3`:

```
docker build -t dockerapp:v0.3 .
Sending build context to Docker daemon  81.92kB
Step 1/7 : FROM python:3.5
---> ffc8b495cd26
Step 2/7 : RUN pip install Flask==0.11.1 redis==2.10.5
---> Running in d7a93edfc53d


Step 7/7 : CMD ["python", "app.py"]
 ---> Running in fe7a9167d74a
Removing intermediate container fe7a9167d74a
 ---> 4b476422d912
Successfully built 4b476422d912
Successfully tagged dockerapp:v0.3
```

Run `redis`, `dockerapp:v0.3` container linking them.

```
docker run -d -p 5000:5000 --name appv3 --link redis dockerapp:v0.3
5e7d53314c474f7c481cdd18cc9d98ef886dd8a32829bd822a726906df0c3b51
```

Check if redis & app container are up and running:

```      
d docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                                              NAMES
90b8ddc4df72        dockerapp:v0.3         "python app.py"          28 seconds ago      Up 27 seconds       0.0.0.0:5000->5000/tcp                             determined_boyd
9ee3407da1a5        dockerapp:v0.3         "python app.py"          8 minutes ago       Up 7 minutes                                                           appv0.3
bff820edf4f1        redis:3.2.0            "docker-entrypoint.s…"   2 hours ago         Up 10 minutes       6379/tcp                                           redis
5e8b2c5fe1e3        elasticsearch:latest   "/docker-entrypoint.…"   3 weeks ago         Up 10 minutes       0.0.0.0:32769->9200/tcp, 0.0.0.0:32768->9300/tcp   brave_bartik
a8b35e1d2b96        portainer/portainer    "/portainer"             4 months ago        Up 10 minutes       0.0.0.0:9000->9000/tcp                             portainer
redis
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/key_value_links.png)

Check how container are linked. First we log onto appv0.3 and examine `/etc/hosts`. We will notice an entry with an ip for the redis container:

```
cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.4	redis bff820edf4f1
172.17.0.6	90b8ddc4df72
```

Cross check with `redis` app by doing an inspect and search for IPAddress:

```
docker inspect redis | grep IPAddress
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.4",
                    "IPAddress": "172.17.0.4",
```

Ping from app to `redis`:

```
docker exec -it determined_boyd bash
admin@90b8ddc4df72:/app$ ping redis
PING redis (172.17.0.4) 56(84) bytes of data.
64 bytes from redis (172.17.0.4): icmp_seq=1 ttl=64 time=0.125 ms
64 bytes from redis (172.17.0.4): icmp_seq=2 ttl=64 time=0.098 ms
64 bytes from redis (172.17.0.4): icmp_seq=3 ttl=64 time=0.139 ms
64 bytes from redis (172.17.0.4): icmp_seq=4 ttl=64 time=0.154 ms
^C
--- redis ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3068ms
rtt min/avg/max/mdev = 0.098/0.129/0.154/0.020 ms
```  

### Benefits of Docker Container Links

  - The main use for docker container links is when we build an
application with a microservice architecture, we are able to
run many independent components in different containers.
  - Docker creates a secure tunnel between the containers that
doesn’t need to expose any ports externally on the container.

### Automate workflow with docker compose:

Specially when we must run an application that host multiple micro services it's impractical to start each container individually.
For this case we use [Docker Compose](https://docs.docker.com/compose/overview/).
Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. Then, with a single command, you create and start all the services from your configuration.

### Install docker-compose:

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   617    0   617    0     0   1148      0 --:--:-- --:--:-- --:--:--  1146
100 11.1M  100 11.1M    0     0   736k      0  0:00:15  0:00:15 --:--:-- 1624k
```

Make docker-compose executable:

```
chmod +x /usr/local/bin/docker-compose
```

Check docker-compose version:

```
docker-compose version
docker-compose version 1.23.1, build b02f1306
docker-py version: 3.5.0
CPython version: 3.6.7
OpenSSL version: OpenSSL 1.1.0f  25 May 2017
```

Creating a docker-compose file

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/docker-compose.png)

Docker Instructions | Description:
- | -
version | Specify docker version, latest is version 3
services  | Defines micro services in our case python app and redis  
build  | Specifies build path  
ports  | exposes to outside internal port  
depends_on  | specifies execution order, i.e first start redis, then app  
image  | Build container based on img version, first try to find image locally

Additional Compose reference [here](https://docs.docker.com/compose/compose-file/)

Stop docker containers and star using docker-compose:

```
docker ps
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                                              NAMES
90b8ddc4df72        dockerapp:v0.3         "python app.py"          33 minutes ago      Up 33 minutes       0.0.0.0:5000->5000/tcp                             determined_boyd
bff820edf4f1        redis:3.2.0            "docker-entrypoint.s…"   2 hours ago         Up 43 minutes       6379/tcp                                           redis
5e8b2c5fe1e3        elasticsearch:latest   "/docker-entrypoint.…"   3 weeks ago         Up 43 minutes       0.0.0.0:32769->9200/tcp, 0.0.0.0:32768->9300/tcp   brave_bartik
a8b35e1d2b96        portainer/portainer    "/portainer"             4 months ago        Up 43 minutes       0.0.0.0:9000->9000/tcp                             portainer
```

Stop docker:
```
docker stop determined_boyd redis
```

Start docker-compose:

```
docker-compose up
Creating network "dockerapp_default" with the default driver
Building dockerapp
Step 1/7 : FROM python:3.5
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/compose-up.png)

### Docker compose benefits:

  - Manual linking containers and configuring services become impractical when the number of containers grows.
  - Docker compose is a very handy tool to quickly get docker
environment up and running.
  - Docker compose uses yaml files to store the configuration
of all the containers, which removes the burden to maintain
our scripts for docker orchestration.

### Docker-compose commands:

Command | Description
-|-
docker-compose up | starts up all the containers.
docker-compose ps | checks the status of the containers managed by docker compose.
docker-compose logs | outputs colored and aggregated logs for the compose-managed
containers.
docker-compose logs | with dash f option outputs appended log when the log grows.
docker-compose logs | with the container name in the end outputs the logs of a specific
container.
docker-compose stop | stops all the running containers without removing them.
docker-compose rm | removes all the containers.
docker-compose build | rebuilds all the images.

By default, docker compose up will only rebuild the image if the image doesn't exist.
If we want to rebuild the image we need to use the docker compose build command, which will rebuild any images created from the docker files.
