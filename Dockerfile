FROM scylladb/scylla

LABEL author="darkerink, <darkerink@hotmail.com>"

RUN apt update \
    && apt upgrade -y \
    && apt -y install curl locales git wget sudo zip unzip curl \
    && adduser container \
    && apt update -y

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
