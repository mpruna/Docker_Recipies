FROM debian:latest
RUN apt-get update && apt-get upgrade -y
RUN apt-get install git -y
RUN apt-get install vim -y
RUN apt-get install nano -y
