FROM phusion/baseimage

# Use baseimage's init process
CMD ["/sbin/my_init"]

# Install RabbitMQ. (https://github.com/dockerfile/rabbitmq/blob/master/Dockerfile)
RUN \
  apt-get update && \
  apt-get install -y wget make build-essential tcl8.5 gcc && \
  wget -qO - https://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add - && \
  echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server && \
  rm -rf /var/lib/apt/lists/* && \
  rabbitmq-plugins enable rabbitmq_management && \
  echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config


# Define environment variables.
ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Define mount points.
VOLUME ["/data", "/data/log", "/data/mnesia"]

WORKDIR /data

ADD build/server /opt/meathooks/server
ADD scripts/meathooks-start /etc/service/meathooks-server/run
ADD scripts/rabbitmq-start /etc/service/rabbitmq/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
EXPOSE 15672