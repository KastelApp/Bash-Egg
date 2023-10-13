FROM debian:buster

LABEL author="darkerink, <darkerink@hotmail.com>"

RUN apt update \
    && apt upgrade -y \
    && apt -y install curl software-properties-common locales git \
    && apt-get install -y default-jre \
    && apt-get install -y zip unzip \
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
    && apt -y install curl \
    && apt -y install libtool

# Install basic software support
RUN apt-get update && \
    apt-get install -y software-properties-common
    
# Python 2 & 3
RUN apt -y install python python-pip python3 python3-pip

RUN apt-get install -y \
    fonts-liberation \
    gconf-service \
    libappindicator1 \
    libasound2 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libfontconfig1 \
    libgbm-dev \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libicu-dev \
    libjpeg-dev \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpng-dev \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    xdg-utils


# Golang
RUN apt -y install golang

# Misc
RUN apt install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# Installing NodeJS dependencies for AIO.
# RUN npm i -g pm2 nodemon typescript

# RUN corepack enable

# RUN corepack prepare yarn@stable --activate

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
