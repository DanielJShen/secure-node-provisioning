FROM --platform=linux/amd64 debian:bookworm-20260803-slim
LABEL authors="Daniel S"

COPY ./build_iso.sh /opt/
COPY ./preseed.cfg /opt/
COPY ./grub.cfg /opt/

USER root

RUN chmod +x /opt/build_iso.sh
#RUN echo "deb http://ftp.uk.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list
RUN apt update
RUN apt install -y udevil acl libarchive-tools cpio genisoimage qemu-system-x86 syslinux-utils wget xorriso isolinux

ENTRYPOINT ["/opt/build_iso.sh"]
