FROM arm32v5/debian:buster-slim AS buildstep

# hadolint ignore=DL3018


RUN \
apt-get update && \
DEBIAN_FRONTEND="noninteractive" \
TZ="Europe/London" \
apt-get -y install \
erlang-nox=1:21.2.6+dfsg-1 \
erlang-dev=1:21.2.6+dfsg-1 \
git=1:2.20.1-2+deb10u3 \
ca-certificates=20200601~deb10u2 \
build-essential=12.6 \
erlang-ssl=1:21.2.6+dfsg-1 \
openssl=1.1.1d-0+deb10u5 \
libssl-dev=1.1.1d-0+deb10u5 \
--no-install-recommends && \
apt-get autoremove -y &&\
apt-get clean && \
rm -rf /var/lib/apt/lists/*



WORKDIR /opt/gateway_mfr
RUN git clone https://github.com/helium/gateway_mfr.git


WORKDIR /opt/gateway_mfr/gateway_mfr

RUN DEBUG=1 make release


FROM arm32v5/debian:buster-slim

# hadolint ignore=DL3018
RUN \
apt-get update && \
DEBIAN_FRONTEND="noninteractive" \
TZ="Europe/London" \
apt-get -y install \
erlang-nox=1:21.2.6+dfsg-1 \
python3-minimal=3.7.3-1 \
--no-install-recommends && \
apt-get autoremove -y &&\
apt-get clean && \
rm -rf /var/lib/apt/lists/*

WORKDIR /opt/gateway_mfr

COPY --from=buildstep /opt/gateway_mfr/gateway_mfr/_build/prod/rel/gateway_mfr .

COPY nebraScript.sh .
COPY eccProg.py .
RUN chmod +x nebraScript.sh

#ENTRYPOINT ["/opt/gateway_mfr/bin/gateway_mfr", "foreground"]
ENTRYPOINT ["sh" , "/opt/gateway_mfr/nebraScript.sh"]
