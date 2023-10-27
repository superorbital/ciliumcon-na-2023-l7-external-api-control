FROM bitnami/kubectl:1.28.3

USER root

RUN apt-get update && apt-get upgrade -y openssl
RUN groupadd --gid 1000 certs && useradd --uid 1000 cert-user

RUN chown -R 1000:1000 /etc/ssl/certs
RUN echo /usr/local/lib64 > /etc/ld.so.conf.d/openssl3.conf && ldconfig

USER cert-user

COPY ./x509-cert.conf /x509-cert.conf 
COPY ./generate.sh /generate.sh

ENTRYPOINT [ "/bin/bash", "-c", "/generate.sh" ]
