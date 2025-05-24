FROM debian:buster

LABEL author="darkerink, <darkerink@hotmail.com>"

# Set DEBIAN_FRONTEND to noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install essential system utilities and libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # Basic utilities
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
    # Libraries from original Dockerfile
    lzma \ # The lzma utility
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
    # Add user
    adduser --disabled-password --gecos "" container && \
    # Clean up apt cache
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

# Python 3.13 (or latest available 3.13.x)
# Check https://www.python.org/ftp/python/ for the latest version
ENV PYTHON_VERSION 3.13.0
ENV PYTHON_PIP_VERSION 24.0 # Or a more recent version of pip

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Python build dependencies
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    # llvm is sometimes needed for Python build optimizations
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    # git is already installed but good to ensure for pip if it wasn't
    git && \
    # Download Python source
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -O /tmp/Python.tar.xz && \
    mkdir -p /usr/src/python && \
    tar -xJf /tmp/Python.tar.xz -C /usr/src/python --strip-components=1 && \
    rm /tmp/Python.tar.xz && \
    # Configure, compile, and install Python
    cd /usr/src/python && \
    ./configure \
    --enable-optimizations \
    --prefix=/usr/local \
    --enable-shared \
    LDFLAGS="-Wl,-rpath=/usr/local/lib" \
    --with-ensurepip=install && \
    make -j$(nproc) && \
    make altinstall && \
    # Create symlinks for python3 and pip3
    ln -s /usr/local/bin/python$(echo $PYTHON_VERSION | cut -d. -f1,2) /usr/local/bin/python3 && \
    ln -s /usr/local/bin/pip$(echo $PYTHON_VERSION | cut -d. -f1,2) /usr/local/bin/pip3 && \
    # Upgrade pip for the new Python
    /usr/local/bin/python3 -m pip install --no-cache-dir --upgrade pip~=$PYTHON_PIP_VERSION setuptools wheel && \
    # Clean up build artifacts
    cd / && \
    rm -rf /usr/src/python && \
    # Consider a multi-stage build for more aggressive cleanup of build dependencies
    # For now, just autoremove and clean apt
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Go (using 1.22.1 as per original, update if needed)
ENV GO_VERSION 1.22.1
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -o go${GO_VERSION}.linux-amd64.tar.gz https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Go environment variables
# Ensure /usr/local/bin (for Python) is in PATH and takes precedence
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=/usr/local/bin:$GOROOT/bin:$GOPATH/bin:$PATH

# Switch to non-root user
USER container
ENV USER=container
ENV HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
