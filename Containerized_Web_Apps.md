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
docker ps -a
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS                           PORTS                                              NAMES
311915ce51e1        dockerapp:v0.3         "python app.py"          3 seconds ago       Up 3 seconds                     0.0.0.0:5000->5000/tcp                             recursing_bassi
bff820edf4f1        redis:3.2.0            "docker-entrypoint.s…"   44 minutes ago      Up 31 minutes                    6379/tcp                                           redis
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/key_value_links.png)
