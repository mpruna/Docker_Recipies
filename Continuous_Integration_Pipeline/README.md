### Running Unit Tests inside Docker

In computer programming, [unit testing](https://en.wikipedia.org/wiki/Unit_testing) is a software testing method by which individual units of source code, sets of one or more computer program modules together with associated control data, usage procedures, and operating procedures, are tested to determine whether they are fit for use.

  - Unit tests should test some basic functionality of our docker app code,
with no reliance on external services.
  - Unit tests should run as quickly as possible so that developers can iterate
much faster without being blocked by waiting for the tests results.
  - Docker containers can spin up in seconds and can create a clean and
isolated environment which is great tool to run unit tests with.

For this section we sill use python unit testing framework

References:
  - [The Python unit testing framework](https://docs.python.org/2/library/unittest.html), sometimes referred to as “PyUnit,” is a Python language version of JUnit, by Kent Beck and Erich Gamma. JUnit is, in turn, a Java version of Kent’s Smalltalk testing framework. Each is the de facto standard unit testing framework for its respective language.
  - [The Hitchhiker's Guide](https://docs.python-guide.org/writing/tests/) to unity testing


```
  git stash && git checkout v0.5
  No local changes to save
  Note: checking out 'v0.5'.

  You are in 'detached HEAD' state. You can look around, make experimental
  changes and commit them, and you can discard any commits you make in this
  state without impacting any branches by performing another checkout.

  If you want to create a new branch to retain commits you create, you may
  do so (now or later) by using -b with the checkout command again. Example:

    git checkout -b <new-branch-name>

  HEAD is now at 2e0bb84 Merge branch 'branch-v0.4' into branch-v0.5
```

Python test script will test docker up functionality:
  - first function initializes the test vertion
  - first test case, calls the / URL, with a key value pair and sets the submit value to save, 200 OK represents a successful test case
  - second test case checks the `load` function, 200 OK represents a successful test case

```
import unittest
import app

class TestDockerapp(unittest.TestCase):

    def setUp(self):                      # Setup/initializes a test version of our Docker app
        self.app = app.app.test_client()

    def test_save_value(self):            # Method used to test submit function
        response = self.app.post('/', data=dict(submit='save', key='2', cache_value='two'))
        assert response.status_code == 200
        assert b'2' in response.data
        assert b'two' in response.data

    def test_load_value(self):           # Method used to test load function
        self.app.post('/', data=dict(submit='save', key='2', cache_value='two'))
        response = self.app.post('/', data=dict(submit='load', key='2'))
        assert response.status_code == 200
        assert b'2' in response.data
        assert b'two' in response.data

if __name__=='__main__':
    unittest.main()
```
Docker build

```
docker-compose build
redis uses an image, skipping
Building dockerapp
Step 1/7 : FROM python:3.5
 ---> ffc8b495cd26
Step 2/7 : RUN pip install Flask==0.11.1 redis==2.10.5


Removing intermediate container 4b3eeef9d7ee
 ---> 698781c7ae9a
Successfully built 698781c7ae9a
Successfully tagged dockerapp_dockerapp:latest
```

docker-compose up

```
docker-compose up -d
Creating network "dockerapp_default" with the default driver
Recreating dockerapp_redis_1_63bf73bea6e0 ... done
Recreating dockerapp_dockerapp_1_ea9b90403a90 ... done
```

Running tests:

```
docker-compose run dockerapp python test.py
Starting dockerapp_redis_1_63bf73bea6e0 ... done
..
----------------------------------------------------------------------
Ran 2 tests in 0.020s

OK
```


### Incorporating Unit Tests into Docker Images

Pros:
  - A single image is used through development, testing and
production, which greatly ensures the reliability of our tests.
Cons:
  - It increases the size of the image.

### Fit Docker Technology into Continuous Integration(CI) Process

What is Continuous Integration?
  • Continuous integration is a software engineering practice in which
isolated changes are immediately tested and reported when they are
added to a larger code base.
  • The goal of Continuous integration is to provide rapid feedback so that if
a defect is introduced into the code base, it can be identified and
corrected as soon as possible.


### A Typical CI Pipeline without Docker

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/CI_pipeline.png)

### CI flow without Docker:

  - developers checkout code in local repository
  - when features get done, they are committed to central repository
  - commit would trigger the build process on continuous integration server
  - The build process usually would involve checking latest code base, building the application and running unit and integration tests.
  - the continuous integration server would also assign a build label to the version of the code it just built.
  - The continuous integration server can also be configured to deploy the application to staging
  or production server after it validates the build


### Docker continuous integration:

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/Docker_CI.png)

  - continuous integration server would build the Docker image after it has built the application.
  - The application goes inside the image and continuous integration server pushes the image to a Docker registry.
  - you can pull the newly built image from Docker registry and run the application inside the container on another host it can be development, staging or even production environment.


### CI with GitHub and CircleCI:

GitHub is essential to continuous integration workflow. GitHub allows you to host public git repositories
for free.
We use `CircleCI` as the continuous integration server. [`CircleCI`](https://circleci.com/product/) is a hosted continuous integration solution which allows you to run one concurrent build for free.

### Setup GitHub follow below resources:

  - [Checking for existing SSH keys](https://help.github.com/articles/checking-for-existing-ssh-keys/)
  - [Generating a new SSH key and adding it to the ssh-agent:](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
  - [Adding a new SSH key to your GitHub account:](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)


### Set up SSH keys for GitHub Account
    - SSH keys are a way to identify trusted computers without involving
  password.
    - Generate a SSH key pair and save the private SSH key in your local
  box and add the public key to your GitHub account.
    - Then you can directly push your changes to GitHub repository without
  typing password.

#### Cloning/Forking dockerapp repository onto my GitHub account

```
git clone https://github.com/jleetutorial/dockerapp.git
Cloning into 'dockerapp'...
remote: Enumerating objects: 173, done.
remote: Total 173 (delta 0), reused 0 (delta 0), pack-reused 173
Receiving objects: 100% (173/173), 20.39 KiB | 366.00 KiB/s, done.
Resolving deltas: 100% (59/59), done.
```

### Cloning dockerapp v0.6

```
git clone https://github.com/mpruna/dockerapp.git -b v0.6
Cloning into 'dockerapp'...
remote: Enumerating objects: 173, done.
remote: Total 173 (delta 0), reused 0 (delta 0), pack-reused 173
Receiving objects: 100% (173/173), 20.39 KiB | 2.26 MiB/s, done.
Resolving deltas: 100% (59/59), done.
Note: checking out '054eb8c5915f4834901b3c7337eb792610c906cf'.
```

### Switch to v0.6

```
If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:


git checkout -b <new-branch-name>

git checkout -b v0.6
M	.gitmodules
D	Continuous_Integration_Pipeline/dockerapp
Switched to a new branch 'v0.6'
```

### `CircleCI` configuration walk through:

```
version: 2                               #CircleCI V2
jobs:                                    #Every config file must have a job    
  build:                                 
    working_directory: /dockerapp        #Default working directory for the test
    docker:                              #Specify container images for this job, jobs will run in container
      - image: docker:17.05.0-ce-git     #or Docker in Docker/Define outside container (docker with git)   
    steps:                  
      - checkout                         #checkout code from GitHub              
      - setup_remote_docker              #create docker images for deployment, using a special key
      - run:                             #Install docker-compose in `CI` environment through `python pip`
          name: Install dependencies
          command: |
            apk add --no-cache py-pip=9.0.0-r1
            pip install docker-compose==1.15.0
      - run:                            #Spin out containers and Run test inside cotnainers
          name: Run tests
          command: |
            docker-compose up -d
            docker-compose run dockerapp python test.py
```

### Inside CircleCI

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/InsideCI.png)


### Running `CircleCI` build

If we have already a GitHub account we can log into `CircleCI` with those credentials.
From the lest side panel we click:`ADD Project`;`dockerapp`;`Setup Project`;`Start Building`
This project fails because we used dockerapp:latest imaged and by default this pushes the image to DockerHub, but we didn't provide credentials.

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/CIfailed.png)


But the whole purpose of continuous integration is that a build will automatically trigger a commit when a code is pushed to the central repository. This time let's tag this project v0.6 and it should work, because we are not using the latest tag.


```
git checkout v0.6
Note: checking out 'v0.6'.

git checkout v0.6
Note: checking out 'v0.6'.
```

### Add a different tag to `Circle CI` build

```
git checkout v0.6
Note: checking out 'v0.6'.
```

### Add dummy test file and commit:

```
git add dummy.txt

git commit -m "Added dummy txt to Circle CI build"
[test-ci c2ab42c] Added dummy txt to Circle CI build
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 dummy.txt
```

### Push branch to remote:

```
git push --set-upstream origin test-ci
Username for 'https://github.com': mpruna
Password for 'https://mpruna@github.com':
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 4 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 288 bytes | 288.00 KiB/s, done.
Total 3 (delta 1), reused 1 (delta 0)
remote: Resolving deltas: 100% (1/1), completed with 1 local object.
remote:
remote: Create a pull request for 'test-ci' on GitHub by visiting:
remote:      https://github.com/mpruna/dockerapp/pull/new/test-ci
remote:
To https://github.com/mpruna/dockerapp.git
 * [new branch]      test-ci -> test-ci
Branch 'test-ci' set up to track remote branch 'test-ci' from 'origin'.
```

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/CI_build_success.png)


### Test run ok

![IMG](https://github.com/mpruna/Docker_Recipies/blob/master/images/test_run_ok.png)
