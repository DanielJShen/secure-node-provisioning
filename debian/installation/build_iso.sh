#!/usr/bin/env bash
set -euxo pipefail
cd "/opt/"

# Fetch iso if it doesn't already exist
ISO_FILE="debian-13.6.0-amd64-netinst.iso"
ISO_PATH="/opt/build/source/${ISO_FILE}"
if test ! -f "${ISO_PATH}"; then
  wget --directory-prefix="/opt/build/source/" https://cdimage.debian.org/debian-cd/13.6.0/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso
fi

# Extract iso files
mkdir isofiles
bsdtar -C isofiles/ -xf "${ISO_PATH}"

# Insert install config
chmod +w -R isofiles/install.amd/
gunzip isofiles/install.amd/initrd.gz
echo /opt/preseed.cfg \
 | cpio -H newc -o -A -F isofiles/install.amd/initrd
gzip isofiles/install.amd/initrd
chmod -w -R isofiles/install.amd/

# Regenerate MD5 Checksum
cd isofiles
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 \
 | xargs -0 md5sum > md5sum.txt \
 || echo "xargs failed with ${?}"
chmod -w md5sum.txt
cd ..

# Build the new ISO
genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o /opt/build/preseed-debian.iso isofiles

# Make the ISO bootable
isohybrid /opt/build/preseed-debian.iso