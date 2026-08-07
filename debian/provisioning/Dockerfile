FROM debian:bookworm-20260803-slim
LABEL authors="Daniel S"

COPY scripts /opt/
COPY playbook-root.yml /opt/
COPY provision.sh /opt/
COPY vars.yml /opt/

RUN apt update
RUN apt install -y ansible
RUN chmod +x /opt/provision.sh

ENTRYPOINT ["/opt/provision.sh"]