FROM debian:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y inetutils-traceroute iproute2 iputils-ping ncat nftables procps tcpdump

ARG EXTRA_PACKAGES=
RUN [ -z "${EXTRA_PACKAGES}" ] || apt-get install -y ${EXTRA_PACKAGES}

COPY --chmod=755 ./scripts /root/scripts

COPY --chmod=755 ./entry-point.sh /root
ENTRYPOINT [ "/root/entry-point.sh" ]

WORKDIR /root

CMD ["sleep", "infinity"]
