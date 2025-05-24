FROM debian:buster

LABEL author="darkerink, <darkerink@hotmail.com>"

# Set DEBIAN_FRONTEND to noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essential system utilities and libraries
# This includes basic utilities, Java runtime, compression tools,
# development libraries, and multimedia support
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl \
    software-properties-common \
    locales \
    git \
    default-jre \
    zip \
    unzip \
    gnupg \
    wget \
    sudo \
    lzma \
    libcurl4 \
    libcurl4-openssl-dev \
    ffmpeg \
    make \
    libtool \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev && \
    adduser --disabled-password --gecos "" container && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# NodeJS (current stable version)
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Python 3.13 installation from source
# Check https://www.python.org/ftp/python/ for the latest version
ENV PYTHON_VERSION 3.13.0
ENV PYTHON_PIP_VERSION 24.0

# Install Python build dependencies and compile Python from source
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    git && \
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -O /tmp/Python.tar.xz && \
    mkdir -p /usr/src/python && \
    tar -xJf /tmp/Python.tar.xz -C /usr/src/python --strip-components=1 && \
    rm /tmp/Python.tar.xz && \
    cd /usr/src/python && \
    ./configure \
    --enable-optimizations \
    --prefix=/usr/local \
    --enable-shared \
    LDFLAGS="-Wl,-rpath=/usr/local/lib" \
    --with-ensurepip=install && \
    make -j$(nproc) && \
    make altinstall && \
    ln -s /usr/local/bin/python$(echo $PYTHON_VERSION | cut -d. -f1,2) /usr/local/bin/python3 && \
    ln -s /usr/local/bin/pip$(echo $PYTHON_VERSION | cut -d. -f1,2) /usr/local/bin/pip3 && \
    /usr/local/bin/python3 -m pip install --no-cache-dir --upgrade pip~=$PYTHON_PIP_VERSION setuptools wheel && \
    cd / && \
    rm -rf /usr/src/python && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Go installation
ENV GO_VERSION 1.22.1
RUN curl -o go${GO_VERSION}.linux-amd64.tar.gz https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables and ensure proper PATH order
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=/usr/local/bin:$GOROOT/bin:$GOPATH/bin:$PATH

# Switch to non-root user
USER container
ENV USER=container
ENV HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
