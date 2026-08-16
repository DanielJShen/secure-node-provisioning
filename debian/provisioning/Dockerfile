FROM debian:bookworm-20260803-slim
LABEL authors="Daniel S"

COPY scripts /opt/scripts
COPY templates /opt/templates
COPY playbook-root.yml /opt/
COPY provision.sh /opt/
COPY vars.yml /opt/
COPY ansible.cfg /etc/ansible/

RUN apt update
RUN apt install -y python3 python3-dnf ansible sshpass uni2ascii
RUN chmod +x /opt/provision.sh

ENTRYPOINT ["/opt/provision.sh"]
