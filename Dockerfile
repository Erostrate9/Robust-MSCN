FROM postgres:12.4

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    git \
    gcc \
    build-essential \
    postgresql-server-dev-12\
    dos2unix

# this will be passed in from the command line
ARG LCARD_USER
#ENV LCARD_USER=$LCARD_USER
ENV POSTGRES_USER=$LCARD_USER
ENV POSTGRES_PASSWORD="password"

RUN useradd -m -s /bin/bash "ceb" && \
    echo "ceb:password" | chpasswd

# scripts in this directory will be run by the postgres docker init script

COPY ./init_db.sh /docker-entrypoint-initdb.d/_init_db.sh

USER root
ADD install_pg_hint.sh /
RUN chmod +x /install_pg_hint.sh
RUN /bin/sh /install_pg_hint.sh

ADD imdb_setup.sh /
ADD stack_setup.sh /
RUN chmod +x /imdb_setup.sh
RUN chmod +x /stack_setup.sh

# Copy the dos2unix utility script to the container
COPY dos2unix.sh /dos2unix.sh
# Grant execute permissions to the dos2unix script
RUN chmod +x /dos2unix.sh
# Run dos2unix on the script
RUN /dos2unix.sh /imdb_setup.sh
RUN /dos2unix.sh /stack_setup.sh

# not running it right away because we want to restart docker container so
# postgresql conf variables take effect


