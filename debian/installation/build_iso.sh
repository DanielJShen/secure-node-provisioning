#!/usr/bin/env bash
set -euxo pipefail
cd "/opt/"

SOURCE_DIR="/opt/build/source"
OUTPUT_DIR="/opt/build/output"
DEFAULT_PRESEED_FILE="/opt/preseed.cfg"

log() {
  echo "[$(date -u)] ${1}" >> "${OUTPUT_DIR}/build.log"
}

findIsoInDir() {
  directory="${1}"
  echo "$( \
    cd "${directory}"; \
    iso_files=(*.iso); \
    echo "${iso_files[0]}")"
}

# Create the output dir if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Fetch iso if one isn't provided already exist
ISO_FILE="$(findIsoInDir ${SOURCE_DIR})"
ISO_PATH="${SOURCE_DIR}/${ISO_FILE}"
if test ! -f "${ISO_PATH}"; then
  ISO_URL="https://cdimage.debian.org/debian-cd/13.6.0/amd64/iso-cd/debian-13.6.0-amd64-netinst.iso"
  log "No iso found, fetching from ${ISO_URL}"
  wget --directory-prefix="${SOURCE_DIR}/" "${ISO_URL}"
  ISO_FILE="$(findIsoInDir ${SOURCE_DIR})"
  ISO_PATH="${SOURCE_DIR}/${ISO_FILE}"
else
  log "Found iso ${ISO_FILE}"
fi

# Fetch preseed.cfg from mounted dir or otherwise use the default
PRESEED_PATH="${SOURCE_DIR}/preseed.cfg"
if test ! -f "${PRESEED_PATH}"; then
  log "No preseed config found, using default"
  PRESEED_PATH="${DEFAULT_PRESEED_FILE}"
else
  log "Using preseed config from build/source/preseed.cfg"
fi

# Extract iso files
mkdir isofiles
bsdtar -C isofiles/ -xf "${ISO_PATH}"

# Insert install config
chmod +w -R isofiles/install.amd/
gunzip isofiles/install.amd/initrd.gz
echo "${PRESEED_PATH}" \
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
            -o "${OUTPUT_DIR}/preseed-debian.iso" isofiles

# Make the ISO bootable
isohybrid "${OUTPUT_DIR}/preseed-debian.iso"

log "ISO Created successfully at 'build/output/preseed-debian.iso'"