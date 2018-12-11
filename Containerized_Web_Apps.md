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
![IMG]https://github.com/mpruna/Docker_Recipies/blob/master/images/http_Flask.png)


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
