FROM debian:buster

MAINTAINER danielpmc, <dan@danbot.host>

RUN apt update \
    && apt upgrade -y \
    && apt -y install curl software-properties-common locales git \
    && apt-get install -y default-jre \
    && apt-get -y install lzma liblzma-dev libcurl4 libcurl4-openssl-dev \
    && adduser container \
    && apt-get update 
    

RUN apt-get -y install gnupg wget
    
RUN curl -fsSL https://packages.redis.io/gpg |  gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" |  tee /etc/apt/sources.list.d/redis.list && \
    apt update && \
    apt install -y redis

RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc |  apt-key add - && \
    echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/6.0 main" |  tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt update && \
    apt install -y mongodb-org

# Grant sudo permissions to container user for commands
RUN apt-get update && \
    apt-get -y install sudo

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_current.x | bash - \
    && apt -y install nodejs \
    && apt -y install ffmpeg \
    && apt -y install make \
    && apt -y install build-essential \
    && apt -y install wget \ 
    && apt -y install curl
    
# Install basic software support
RUN apt-get update && \
    apt-get install -y software-properties-common
    
# Python 2 & 3
RUN apt -y install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
RUN wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz
RUN tar -xf Python-3.10.*.tgz
RUN cd Python-3.10.0 && ./configure --enable-optimizations && make -j 8 && make altinstall
RUN rm -rf Python-3.10.0
RUN rm Python-3.10.0.tgz
RUN apt -y install python python-pip python3-pip
RUN pip3 install --upgrade pip

# Golang
RUN apt -y install golang

# Installing NodeJS dependencies for AIO.
RUN npm i -g yarn pm2

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
