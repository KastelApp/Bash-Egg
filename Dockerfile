FROM debian:buster

LABEL author="darkerink, <darkerink@hotmail.com>"

# Set DEBIAN_FRONTEND to noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# System dependencies, including build tools for Python
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
    # Python build dependencies
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \ # Sometimes needed for optimizations
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    # Other dependencies from original file
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
    # Add user after system packages are installed
    adduser --disabled-password --gecos "" container && \
    # Clean up apt cache
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# NodeJS (current version)
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
    apt-get install -y --no-install-recommends wget build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev git && \
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
    # Ensure /usr/local/bin is in PATH and preferred
    # Create symlinks for python3 and pip3 to the new version
    # altinstall creates python3.13, pip3.13 etc.
    ln -s /usr/local/bin/python$(echo $PYTHON_VERSION | cut -d. -f1,2) /usr/local/bin/python3 && \
    ln -s /usr/local/bin/pip$(echo $PYTHON_VERSION | cut -d. -f1,2) /usr/local/bin/pip3 && \
    # Upgrade pip for the new Python
    /usr/local/bin/python3 -m pip install --no-cache-dir --upgrade pip~=$PYTHON_PIP_VERSION setuptools wheel && \
    # Clean up build artifacts and dependencies (some -dev packages might be needed if C extensions are built later)
    # For a smaller image, use a multi-stage build
    cd / && \
    rm -rf /usr/src/python && \
    # The following line is aggressive and might remove dev packages needed by other tools.
    # Consider a multi-stage build for proper cleanup.
    # apt-get purge -y --auto-remove build-essential llvm && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Go 1.22.1 (or update to a newer version if desired)
ENV GO_VERSION 1.22.1
RUN curl -o go${GO_VERSION}.linux-amd64.tar.gz https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
# Also ensure /usr/local/bin (for Python) is in PATH and takes precedence
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
